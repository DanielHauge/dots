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
SUDO_KEEPALIVE_PID=''

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
    echo "Usage: $(basename "$0") [-y] [--dry-run]"
    echo "  -y    install missing packages only"
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

load_all_installed_packages() {
    pacman -Qq | LC_ALL=C sort -u
}

require_paru() {
    if ! command -v paru >/dev/null 2>&1 || ! paru --version >/dev/null 2>&1; then
        echo "paru is missing or cannot run; rerun arch/install.sh to bootstrap it." >&2
        exit 1
    fi
}

start_sudo_keepalive() {
    sudo -v
    (
        while true; do
            sleep 45
            sudo -n true || exit
        done
    ) &
    SUDO_KEEPALIVE_PID=$!
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

run_action() {
    local action=$1

    case "$action" in
    [Yy] | install-missing)
        install_missing_packages
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

    printf '\n%s%sChoose action%s [Y] install missing, [N] do nothing: ' \
        "$COLOR_BOLD" "$COLOR_BLUE" "$COLOR_RESET"
    read -r action || action=''

    if [[ "$DRY_RUN" == false && "$action" =~ ^[Yy]$ ]]; then
        start_sudo_keepalive
    fi
    run_action "$action"
}

while (($# > 0)); do
    case "$1" in
    -y)
        if [[ -n "$ACTION" ]]; then
            echo "Only one -y option can be used at a time." >&2
            exit 1
        fi
        ACTION='install-missing'
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
TMP_INSTALLED_ALL=$(mktemp)
TMP_MISSING=$(mktemp)

cleanup() {
    if [[ -n "$SUDO_KEEPALIVE_PID" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
        wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi
    rm -f "$TMP_DESIRED" "$TMP_INSTALLED_ALL" "$TMP_MISSING"
}
trap cleanup EXIT

load_desired_packages >"$TMP_DESIRED"
load_all_installed_packages >"$TMP_INSTALLED_ALL"
comm -13 "$TMP_INSTALLED_ALL" "$TMP_DESIRED" >"$TMP_MISSING"

print_header "Package sync overview"
print_note "Missing packages are enforced from your main lists." "$COLOR_BLUE"

print_list "Missing packages" "$TMP_MISSING" "Nothing missing." "$COLOR_YELLOW"

if [[ ! -s "$TMP_MISSING" ]]; then
    print_note "System already matches your package sync rules." "$COLOR_GREEN"
    exit 0
fi

if [[ -n "$ACTION" ]]; then
    if [[ "$DRY_RUN" == false ]]; then
        start_sudo_keepalive
    fi
    run_action "$ACTION"
else
    prompt_for_action
fi
