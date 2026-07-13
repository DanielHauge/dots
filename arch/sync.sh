#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DOTS_LOC=${DOTS_LOC:-$(cd -- "$SCRIPT_DIR/.." && pwd)}
PACKAGE_DIR="$DOTS_LOC/arch/packages"
LEGACY_PACKAGE_FILE="$DOTS_LOC/arch/packages.txt"
EXTRAS_PACKAGE_FILE="$PACKAGE_DIR/extras.txt"
ACTION=''
DRY_RUN=false

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    COLOR_RESET=$'\033[0m'
    COLOR_BOLD=$'\033[1m'
    COLOR_RED=$'\033[31m'
    COLOR_GREEN=$'\033[32m'
    COLOR_YELLOW=$'\033[33m'
    COLOR_BLUE=$'\033[34m'
    COLOR_CYAN=$'\033[36m'
else
    COLOR_RESET=''
    COLOR_BOLD=''
    COLOR_RED=''
    COLOR_GREEN=''
    COLOR_YELLOW=''
    COLOR_BLUE=''
    COLOR_CYAN=''
fi

usage() {
    echo "Usage: $(basename "$0") [-a | -y | -r] [--dry-run]"
    echo "  -a    install missing packages and remove dangling explicit packages"
    echo "  -y    install missing packages only"
    echo "  -r    remove dangling explicit packages only"
    echo "  --dry-run  show package changes without applying them"
    echo "  -h    show this help"
}

print_header() {
    printf '\n%s%s== %s ==%s\n' "$COLOR_BOLD" "$COLOR_CYAN" "$1" "$COLOR_RESET"
}

print_note() {
    printf '%s%s%s\n' "$2" "$1" "$COLOR_RESET"
}

print_list() {
    local title=$1
    local file=$2
    local empty_message=$3
    local color=$4
    local -a packages=()

    mapfile -t packages <"$file"

    printf '\n%s%s%s (%d)%s\n' "$COLOR_BOLD" "$color" "$title" "${#packages[@]}" "$COLOR_RESET"
    if ((${#packages[@]} == 0)); then
        printf '  %s\n' "$empty_message"
        return
    fi

    printf '  - %s\n' "${packages[@]}"
}

normalize_package_stream() {
    sed -e 's/[[:space:]]*#.*//' \
        -e 's/\r$//' \
        -e '/^[[:space:]]*$/d' |
        awk '{print $1}' |
        LC_ALL=C sort -u
}

load_package_files() {
    local include_extras=$1

    if [[ ! -d "$PACKAGE_DIR" ]]; then
        return 1
    fi

    if [[ "$include_extras" == true ]]; then
        find "$PACKAGE_DIR" -type f -name '*.txt' -print0 | LC_ALL=C sort -z
    else
        find "$PACKAGE_DIR" -type f -name '*.txt' ! -name 'extras.txt' -print0 | LC_ALL=C sort -z
    fi
}

load_desired_packages() {
    if [[ -d "$PACKAGE_DIR" ]]; then
        local -a package_files=()
        mapfile -d '' -t package_files < <(load_package_files false)
        if ((${#package_files[@]} == 0)); then
            echo "No enforced package list files found in $PACKAGE_DIR" >&2
            exit 1
        fi

        cat -- "${package_files[@]}"
    elif [[ -f "$LEGACY_PACKAGE_FILE" ]]; then
        cat -- "$LEGACY_PACKAGE_FILE"
    else
        echo "Could not find package lists in $PACKAGE_DIR or $LEGACY_PACKAGE_FILE" >&2
        exit 1
    fi | normalize_package_stream
}

load_whitelisted_packages() {
    if [[ -f "$EXTRAS_PACKAGE_FILE" ]]; then
        cat -- "$EXTRAS_PACKAGE_FILE" | normalize_package_stream
    fi
}

build_extra_package_list() {
    local package=''
    local rule=''
    local is_whitelisted=false
    local -a whitelist_rules=()

    if [[ -s "$TMP_WHITELIST" ]]; then
        mapfile -t whitelist_rules <"$TMP_WHITELIST"
    fi

    while IFS= read -r package; do
        if grep -Fxq -- "$package" "$TMP_DESIRED"; then
            continue
        fi

        is_whitelisted=false
        for rule in "${whitelist_rules[@]}"; do
            # shellcheck disable=SC2254 # extras.txt intentionally supports glob patterns like texlive-*
            case "$package" in
            $rule)
                is_whitelisted=true
                break
                ;;
            esac
        done

        if [[ "$is_whitelisted" == false ]]; then
            printf '%s\n' "$package"
        fi
    done <"$TMP_INSTALLED_EXPLICIT"
}

load_all_installed_packages() {
    pacman -Qq | LC_ALL=C sort -u
}

load_explicit_packages() {
    pacman -Qqe | LC_ALL=C sort -u
}

require_paru() {
    if ! command -v paru >/dev/null 2>&1; then
        echo "paru is required to apply package changes." >&2
        exit 1
    fi
}

install_missing_packages() {
    local -a missing_packages=()
    mapfile -t missing_packages <"$TMP_MISSING"

    if ((${#missing_packages[@]} == 0)); then
        print_note "Nothing to install." "$COLOR_GREEN"
        return
    fi

    print_header "Installing missing packages"
    printf '  - %s\n' "${missing_packages[@]}"
    if [[ "$DRY_RUN" == true ]]; then
        print_note "Dry run: packages were not installed." "$COLOR_YELLOW"
        return
    fi
    require_paru
    paru -S --needed --noconfirm -- "${missing_packages[@]}"
}

remove_extra_packages() {
    local -a extra_packages=()
    local -a orphan_packages=()

    mapfile -t extra_packages <"$TMP_EXTRA"
    if ((${#extra_packages[@]} == 0)); then
        print_note "Nothing to remove." "$COLOR_GREEN"
        return
    fi

    print_header "Removing non-listed packages"
    printf '  - %s\n' "${extra_packages[@]}"
    if [[ "$DRY_RUN" == true ]]; then
        print_note "Dry run: packages were not removed." "$COLOR_YELLOW"
        return
    fi
    require_paru
    paru -Rns --noconfirm -- "${extra_packages[@]}"

    if pacman -Qdtq >/dev/null 2>&1; then
        mapfile -t orphan_packages < <(pacman -Qdtq)
        if ((${#orphan_packages[@]} > 0)); then
            print_header "Removing orphaned dependencies"
            printf '  - %s\n' "${orphan_packages[@]}"
            paru -Rns --noconfirm -- "${orphan_packages[@]}"
        fi
    fi

    print_header "Cleaning package caches"
    paru -c --noconfirm
    paru -Scc --noconfirm
}

run_action() {
    local action=$1

    case "$action" in
    [Aa] | sync-all)
        install_missing_packages
        remove_extra_packages
        ;;
    [Yy] | install-missing)
        install_missing_packages
        ;;
    [Rr] | remove-extra)
        remove_extra_packages
        ;;
    [Nn] | '')
        print_note "No changes applied." "$COLOR_YELLOW"
        ;;
    *)
        print_note "No changes applied." "$COLOR_YELLOW"
        ;;
    esac
}

prompt_for_action() {
    local action=''

    printf '\n%s%sChoose action%s [A] install missing + remove dangling, [Y] install missing, [R] remove dangling, [N] do nothing: ' \
        "$COLOR_BOLD" "$COLOR_BLUE" "$COLOR_RESET"
    read -r action || action=''

    run_action "$action"
}

while (($# > 0)); do
    case "$1" in
    -a)
        if [[ -n "$ACTION" ]]; then
            echo "Only one of -a, -y, or -r can be used at a time." >&2
            exit 1
        fi
        ACTION='sync-all'
        ;;
    -y)
        if [[ -n "$ACTION" ]]; then
            echo "Only one of -a, -y, or -r can be used at a time." >&2
            exit 1
        fi
        ACTION='install-missing'
        ;;
    -r)
        if [[ -n "$ACTION" ]]; then
            echo "Only one of -a, -y, or -r can be used at a time." >&2
            exit 1
        fi
        ACTION='remove-extra'
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    --dry-run)
        DRY_RUN=true
        ;;
    *)
        usage >&2
        exit 1
        ;;
    esac
    shift
done

TMP_DESIRED=$(mktemp)
TMP_WHITELIST=$(mktemp)
TMP_INSTALLED_ALL=$(mktemp)
TMP_INSTALLED_EXPLICIT=$(mktemp)
TMP_EXTRA=$(mktemp)
TMP_MISSING=$(mktemp)

cleanup() {
    rm -f "$TMP_DESIRED" "$TMP_WHITELIST" "$TMP_INSTALLED_ALL" "$TMP_INSTALLED_EXPLICIT" "$TMP_EXTRA" "$TMP_MISSING"
}
trap cleanup EXIT

load_desired_packages >"$TMP_DESIRED"
load_whitelisted_packages >"$TMP_WHITELIST"
load_all_installed_packages >"$TMP_INSTALLED_ALL"
load_explicit_packages >"$TMP_INSTALLED_EXPLICIT"
build_extra_package_list >"$TMP_EXTRA"
comm -13 "$TMP_INSTALLED_ALL" "$TMP_DESIRED" >"$TMP_MISSING"

print_header "Package sync overview"
print_note "Missing packages are enforced from your main lists." "$COLOR_BLUE"
print_note "Removal candidates are based on explicitly installed packages only." "$COLOR_BLUE"
if [[ -s "$TMP_WHITELIST" ]]; then
    print_note "extras.txt is treated as a whitelist: exact names and glob patterns are ignored for removal and not enforced." "$COLOR_BLUE"
fi

print_list "Missing packages" "$TMP_MISSING" "Nothing missing." "$COLOR_YELLOW"
print_list "Non-listed explicitly installed packages" "$TMP_EXTRA" "Nothing dangling." "$COLOR_RED"

if [[ ! -s "$TMP_MISSING" && ! -s "$TMP_EXTRA" ]]; then
    print_note "System already matches your package sync rules." "$COLOR_GREEN"
    exit 0
fi

if [[ -n "$ACTION" ]]; then
    run_action "$ACTION"
else
    prompt_for_action
fi
