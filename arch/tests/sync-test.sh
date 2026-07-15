#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SYNC="$SCRIPT_DIR/../sync.sh"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/dots/arch/packages"
printf 'test-package\n' >"$TMP_DIR/dots/arch/packages/core.txt"

cat >"$TMP_DIR/bin/pacman" <<'EOF'
#!/usr/bin/env bash
case "$1" in
-Qq | -Qqe)
    exit 0
    ;;
esac
EOF
cat >"$TMP_DIR/bin/paru" <<'EOF'
#!/usr/bin/env bash
exit 127
EOF
chmod +x "$TMP_DIR/bin/pacman" "$TMP_DIR/bin/paru"

if PATH="$TMP_DIR/bin:$PATH" DOTS_LOC="$TMP_DIR/dots" bash "$SYNC" -y >"$TMP_DIR/output" 2>&1; then
    echo "sync must fail when paru cannot execute." >&2
    exit 1
fi

grep -Fq 'paru is missing or cannot run; rerun arch/install.sh to bootstrap it.' "$TMP_DIR/output"
