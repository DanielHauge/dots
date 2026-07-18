#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
INIT="$SCRIPT_DIR/../init.sh"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/home"
LOG="$TMP_DIR/log"

cat >"$TMP_DIR/bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf 'sudo %s\n' "$*" >>"$LOG"
"$@"
EOF

cat >"$TMP_DIR/bin/pacman" <<'EOF'
#!/usr/bin/env bash
printf 'pacman %s\n' "$*" >>"$LOG"
EOF

cat >"$TMP_DIR/bin/git" <<'EOF'
#!/usr/bin/env bash
printf 'git %s\n' "$*" >>"$LOG"
if [[ "$1" == clone ]]; then
    destination=$3
    mkdir -p "$destination/.git" "$destination/arch"
    cat >"$destination/arch/install.sh" <<'INSTALLER'
#!/usr/bin/env bash
printf 'installer %s\n' "$*" >>"$LOG"
INSTALLER
    chmod +x "$destination/arch/install.sh"
fi
EOF
chmod +x "$TMP_DIR/bin/sudo" "$TMP_DIR/bin/pacman" "$TMP_DIR/bin/git"

export PATH="$TMP_DIR/bin:$PATH"
export LOG
HOME="$TMP_DIR/home" USER=desktop bash "$INIT"
grep -Fxq 'sudo pacman -Syu --noconfirm --needed git' "$LOG"
grep -Fq 'git clone https://github.com/DanielHauge/dots.git' "$LOG"
grep -Fxq 'installer ' "$LOG"

: >"$LOG"
HOME="$TMP_DIR/home" USER=desktop bash "$INIT"
grep -Fq 'git -C '"$TMP_DIR"'/home/dots fetch --quiet origin' "$LOG"
grep -Fq 'git -C '"$TMP_DIR"'/home/dots pull --ff-only --quiet' "$LOG"

: >"$LOG"
HOME="$TMP_DIR/home" USER=desktop bash "$INIT" --dry-run
grep -Fxq 'installer --dry-run' "$LOG"
if grep -Fq 'pacman ' "$LOG" || grep -Fq 'git ' "$LOG"; then
    echo "Dry run must not bootstrap packages or update the checkout." >&2
    exit 1
fi

: >"$LOG"
HOME="$TMP_DIR/home" USER=desktop bash "$INIT" --boot-stack refind-uki --dry-run
grep -Fxq 'installer --dry-run --boot-stack refind-uki' "$LOG"

# shellcheck disable=SC1090
source "$INIT"
is_root() { return 0; }
# shellcheck disable=SC2034
TARGET_USER=desktop
TARGET_HOME="$TMP_DIR/home"
runuser() { printf 'runuser %s\n' "$*" >>"$LOG"; }
getent() {
    [[ "$1" == passwd && "$2" == desktop ]] || return 2
    printf 'desktop:x:1000:1000::%s:/bin/bash\n' "$TARGET_HOME"
}
id() {
    [[ "$1" == -u && "$2" == desktop ]] || return 2
    printf '1000\n'
}
run_as_target git status
grep -Fq 'runuser -u desktop -- env HOME='"$TMP_DIR"'/home USER=desktop LOGNAME=desktop' "$LOG"

if (export TARGET_USER=; validate_target_user) >/dev/null 2>&1; then
    echo "Root bootstrap must require --user." >&2
    exit 1
fi
