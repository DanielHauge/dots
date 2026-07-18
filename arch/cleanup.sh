#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DOTS_LOC=${DOTS_LOC:-$(cd -- "$SCRIPT_DIR/.." && pwd)}
PACKAGE_DIR="$DOTS_LOC/arch/packages"
LEGACY_PACKAGE_FILE="$DOTS_LOC/arch/packages.txt"
EXTRAS_PACKAGE_FILE="$PACKAGE_DIR/extras.txt"
DRY_RUN=false
SUDO_KEEPALIVE_PID=''
# Archinstall-owned boot CPU microcode and graphics drivers are outside this repo's manifests.
PROTECTED_PACKAGE_RULES=(
    intel-ucode amd-ucode nvidia\* lib32-nvidia\* mesa lib32-mesa
    vulkan-intel vulkan-radeon vulkan-nouveau
    lib32-vulkan-intel lib32-vulkan-radeon lib32-vulkan-nouveau
    xf86-video-amdgpu xf86-video-ati xf86-video-intel xf86-video-nouveau
)

usage() {
    echo "Usage: $(basename "$0") [--dry-run]"
    echo "  --dry-run  show packages that would be removed"
}

normalize_package_stream() {
    sed -e 's/[[:space:]]*#.*//' -e 's/\r$//' -e '/^[[:space:]]*$/d' | awk '{print $1}' | LC_ALL=C sort -u
}

load_desired_packages() {
    if [[ -d "$PACKAGE_DIR" ]]; then
        local -a files=()
        mapfile -d '' -t files < <(find "$PACKAGE_DIR" -type f -name '*.txt' ! -name 'extras.txt' -print0 | LC_ALL=C sort -z)
        ((${#files[@]})) || { echo "No enforced package list files found in $PACKAGE_DIR" >&2; exit 1; }
        cat -- "${files[@]}"
    elif [[ -f "$LEGACY_PACKAGE_FILE" ]]; then
        cat -- "$LEGACY_PACKAGE_FILE"
    else
        echo "Could not find package lists in $PACKAGE_DIR or $LEGACY_PACKAGE_FILE" >&2
        exit 1
    fi | normalize_package_stream
}

build_extra_package_list() {
    local package rule
    local -a whitelist_rules=()
    [[ -s "$TMP_WHITELIST" ]] && mapfile -t whitelist_rules <"$TMP_WHITELIST"
    while IFS= read -r package; do
        grep -Fxq -- "$package" "$TMP_DESIRED" && continue
        for rule in "${PROTECTED_PACKAGE_RULES[@]}"; do
            case "$package" in $rule) continue 2 ;; esac
        done
        for rule in "${whitelist_rules[@]}"; do
            # shellcheck disable=SC2254 # extras.txt intentionally supports glob patterns.
            case "$package" in $rule) continue 2 ;; esac
        done
        printf '%s\n' "$package"
    done <"$TMP_INSTALLED_EXPLICIT"
}

require_paru() {
    command -v paru >/dev/null 2>&1 && paru --version >/dev/null 2>&1 || {
        echo "paru is missing or cannot run; rerun arch/install.sh to bootstrap it." >&2
        exit 1
    }
}

start_sudo_keepalive() {
    sudo -v
    (while true; do sleep 45; sudo -n true || exit; done) &
    SUDO_KEEPALIVE_PID=$!
}

cleanup() {
    [[ -z "$SUDO_KEEPALIVE_PID" ]] || { kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true; wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true; }
    rm -f "$TMP_DESIRED" "$TMP_WHITELIST" "$TMP_INSTALLED_EXPLICIT" "$TMP_EXTRA"
}

while (($#)); do
    case "$1" in
    --dry-run) DRY_RUN=true ;;
    -h | --help) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
    esac
    shift
done

TMP_DESIRED=$(mktemp)
TMP_WHITELIST=$(mktemp)
TMP_INSTALLED_EXPLICIT=$(mktemp)
TMP_EXTRA=$(mktemp)
trap cleanup EXIT

load_desired_packages >"$TMP_DESIRED"
if [[ -f "$EXTRAS_PACKAGE_FILE" ]]; then
    normalize_package_stream <"$EXTRAS_PACKAGE_FILE" >"$TMP_WHITELIST"
fi
pacman -Qqe | LC_ALL=C sort -u >"$TMP_INSTALLED_EXPLICIT"
build_extra_package_list >"$TMP_EXTRA"

if [[ ! -s "$TMP_EXTRA" ]]; then
    echo "Nothing to remove."
    exit 0
fi

mapfile -t extra_packages <"$TMP_EXTRA"
printf 'Packages outside the manifests:\n'
printf '  - %s\n' "${extra_packages[@]}"
if [[ "$DRY_RUN" == true ]]; then
    echo "Dry run: packages were not removed."
    exit 0
fi

read -r -p 'Remove these packages, orphaned dependencies, and clean caches? [y/N] ' reply
[[ "$reply" =~ ^[Yy]$ ]] || { echo "No changes applied."; exit 0; }

require_paru
start_sudo_keepalive
paru -Rns --noconfirm -- "${extra_packages[@]}"
if pacman -Qdtq >/dev/null 2>&1; then
    mapfile -t orphan_packages < <(pacman -Qdtq)
    ((${#orphan_packages[@]} == 0)) || paru -Rns --noconfirm -- "${orphan_packages[@]}"
fi
paru -c --noconfirm
paru -Scc --noconfirm
