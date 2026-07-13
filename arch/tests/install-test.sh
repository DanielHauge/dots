#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
INSTALLER="$SCRIPT_DIR/../install.sh"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir "$TMP_DIR/bin"
cat >"$TMP_DIR/bin/lspci" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' '01:00.0 0300: 10de:2684 (rev a1)'
EOF
chmod +x "$TMP_DIR/bin/lspci"

PATH="$TMP_DIR/bin:$PATH"
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
