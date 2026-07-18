#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CLEANUP="$SCRIPT_DIR/../cleanup.sh"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/dots/arch/packages"
printf 'managed-package\n' >"$TMP_DIR/dots/arch/packages/core.txt"
cat >"$TMP_DIR/bin/pacman" <<'EOF'
#!/usr/bin/env bash
[[ "$1" == -Qqe ]] && printf '%s\n' managed-package intel-ucode nvidia-dkms lib32-nvidia-utils mesa vulkan-radeon
EOF
chmod +x "$TMP_DIR/bin/pacman"

PATH="$TMP_DIR/bin:$PATH" DOTS_LOC="$TMP_DIR/dots" bash "$CLEANUP" --dry-run >"$TMP_DIR/output"
grep -Fxq 'Nothing to remove.' "$TMP_DIR/output"
