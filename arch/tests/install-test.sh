#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
INSTALLER="$SCRIPT_DIR/../install.sh"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
LOG="$TMP_DIR/log"

mkdir "$TMP_DIR/bin"
cat >"$TMP_DIR/bin/lspci" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' '01:00.0 0300: 10de:2684 (rev a1)'
EOF
chmod +x "$TMP_DIR/bin/lspci"
cat >"$TMP_DIR/bin/sudo" <<'EOF'
#!/usr/bin/env bash
[[ "$1" == -v ]]
EOF
chmod +x "$TMP_DIR/bin/sudo"

PATH="$TMP_DIR/bin:$PATH"
# shellcheck disable=SC1090
source "$INSTALLER"
SELECTED_PROFILES=()
detect_profiles

[[ " ${SELECTED_PROFILES[*]} " == *" nvidia "* ]]
validate_profiles

source_file="$TMP_DIR/source"
target_file="$TMP_DIR/target"
conflict_file="$TMP_DIR/conflict"
touch "$source_file" "$conflict_file"
link_path "$source_file" "$target_file"
[[ -L "$target_file" ]]
link_path "$source_file" "$target_file"

link_path "$source_file" "$conflict_file"
[[ -L "$conflict_file" ]]

HOME="$TMP_DIR/home"
deploy_dotfiles
deploy_dotfiles
[[ -L "$HOME/.config/nvim" ]]
[[ -L "$HOME/.gitconfig" ]]
[[ -L "$HOME/.zshrc" ]]

if (
    SELECTED_PROFILES=(invalid)
    validate_profiles
) >/dev/null 2>&1; then
    echo "Unknown profiles must fail validation." >&2
    exit 1
fi

main --check --profile intel >/dev/null

/usr/bin/grep -Fxq 'rustup' "$(dirname "$INSTALLER")/packages/dev.txt"
if /usr/bin/grep -Fxq 'rust' "$(dirname "$INSTALLER")/packages/dev.txt"; then
    echo "The package manifest must use rustup as the workstation Rust toolchain." >&2
    exit 1
fi

ORIGINAL_PATH=$PATH
: >"$LOG"
sudo() {
    printf 'sudo %s\n' "$*" >>"$LOG"
}
pacman() {
    if [[ "$1" == -Q ]]; then
        return 1
    fi
    printf 'pacman %s\n' "$*" >>"$LOG"
}
git() {
    printf 'git %s\n' "$*" >>"$LOG"
    if [[ "$1" == clone ]]; then
        /usr/bin/mkdir -p "$3"
    fi
}
makepkg() {
    printf 'makepkg %s\n' "$*" >>"$LOG"
}
mktemp() {
    /usr/bin/mktemp "$@"
}
rm() {
    /usr/bin/rm "$@"
}

PATH="$TMP_DIR/bin"
ensure_paru
/usr/bin/grep -Fxq 'sudo pacman -Syu --needed --noconfirm base-devel git' "$LOG"
/usr/bin/grep -Fq 'git clone https://aur.archlinux.org/paru.git ' "$LOG"
/usr/bin/grep -Fxq 'makepkg -si --rmdeps --noconfirm' "$LOG"

: >"$LOG"
/usr/bin/cat >"$TMP_DIR/bin/paru" <<'EOF'
#!/bin/bash
exit 127
EOF
/usr/bin/chmod +x "$TMP_DIR/bin/paru"
ensure_paru
/usr/bin/grep -Fxq 'sudo pacman -Syu --needed --noconfirm base-devel git' "$LOG"
/usr/bin/grep -Fq 'git clone https://aur.archlinux.org/paru.git ' "$LOG"
/usr/bin/grep -Fxq 'makepkg -si --rmdeps --noconfirm' "$LOG"
PATH=$ORIGINAL_PATH

: >"$LOG"
(
    # shellcheck disable=SC2329 # Invoked by start_sudo_keepalive from the sourced installer.
    sudo() {
        printf 'sudo %s\n' "$*" >>"$LOG"
        [[ "$1" == -v ]]
    }
    # shellcheck disable=SC2329 # Invoked by start_sudo_keepalive from the sourced installer.
    sleep() { :; }
    start_sudo_keepalive
    wait "$SUDO_KEEPALIVE_PID"
)
/usr/bin/grep -Fxq 'sudo -v' "$LOG"
/usr/bin/grep -Fxq 'sudo -n true' "$LOG"
