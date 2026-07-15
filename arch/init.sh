#!/usr/bin/env bash
set -euo pipefail

REPOSITORY=https://github.com/DanielHauge/dots.git
TARGET_USER=${SUDO_USER:-}
BOOT_STACK=refind-uki
declare -a INSTALL_ARGS=()

usage() {
    cat <<EOF
Usage: $(basename "$0") [--user USER] [--boot-stack refind-uki] [INSTALLER OPTIONS]

Bootstrap and provision this Arch workstation. Run as the desktop user, or as
root with --user USER. Root is used only for the initial pacman step; the
target user owns the checkout and runs the installer.

  --user USER             Target desktop user (required when run as root).
  --boot-stack NAME       Boot stack to provision (default: refind-uki).
  --dry-run, --check      Forward to the installer without provisioning.
  --profile NAME          Forward a hardware profile to the installer.
  -h, --help              Show this help.
EOF
}

fail() {
    echo "Bootstrap: $*" >&2
    exit 1
}

is_root() {
    ((EUID == 0))
}

run_as_target() {
    if is_root; then
        runuser -u "$TARGET_USER" -- env \
            HOME="$TARGET_HOME" USER="$TARGET_USER" LOGNAME="$TARGET_USER" \
            PATH=/usr/local/bin:/usr/bin:/bin \
            bash -c 'exec "$@"' -- "$@"
    else
        "$@"
    fi
}

validate_target_user() {
    if is_root; then
        [[ -n "$TARGET_USER" ]] || fail "root execution requires --user USER."
        getent passwd "$TARGET_USER" >/dev/null || fail "user does not exist: $TARGET_USER"
        TARGET_HOME=$(getent passwd "$TARGET_USER" | awk -F: '{print $6}')
        local target_uid
        target_uid=$(id -u "$TARGET_USER")
        ((target_uid != 0)) || fail "--user must name a non-root desktop account."
        [[ -d "$TARGET_HOME" && -w "$TARGET_HOME" ]] ||
            fail "home directory is not writable for $TARGET_USER: $TARGET_HOME"
    else
        TARGET_USER=${USER:-$(id -un)}
        TARGET_HOME=$HOME
        [[ -z "${1:-}" || "$1" == "$TARGET_USER" ]] ||
            fail "--user must match the invoking desktop user ($TARGET_USER)."
    fi
}

update_checkout() {
    local checkout=$TARGET_HOME/dots

    if [[ -e "$checkout" && ! -d "$checkout/.git" ]]; then
        fail "$checkout exists but is not a git checkout; move it aside before rerunning."
    fi

    if [[ ! -d "$checkout/.git" ]]; then
        echo "Bootstrap: cloning dots into $checkout"
        run_as_target git clone "$REPOSITORY" "$checkout"
        return
    fi

    echo "Bootstrap: updating $checkout"
    run_as_target git -C "$checkout" fetch --quiet origin
    run_as_target git -C "$checkout" pull --ff-only --quiet
}

main() {
    while (($# > 0)); do
        case "$1" in
        --user)
            (($# > 1)) || fail "--user requires a name."
            TARGET_USER=$2
            shift
            ;;
        --boot-stack)
            (($# > 1)) || fail "--boot-stack requires a name."
            BOOT_STACK=$2
            shift
            ;;
        --dry-run | --check)
            INSTALL_ARGS+=("$1")
            ;;
        --profile)
            (($# > 1)) || fail "--profile requires a name."
            INSTALL_ARGS+=("$1" "$2")
            shift
            ;;
        -h | --help)
            usage
            return
            ;;
        *)
            fail "unknown option: $1"
            ;;
        esac
        shift
    done

    validate_target_user "$TARGET_USER"

    if [[ " ${INSTALL_ARGS[*]} " == *" --dry-run "* || " ${INSTALL_ARGS[*]} " == *" --check "* ]]; then
        local checkout=$TARGET_HOME/dots
        [[ -d "$checkout/.git" ]] ||
            fail "$checkout is required for --dry-run or --check; run the bootstrap without either option first."
        echo "Bootstrap: running installer checks as $TARGET_USER"
        run_as_target "$checkout/arch/install.sh" --boot-stack "$BOOT_STACK" "${INSTALL_ARGS[@]}"
        return
    fi

    if is_root; then
        pacman -Syu --noconfirm --needed git
    else
        sudo pacman -Syu --noconfirm --needed git
    fi

    update_checkout
    echo "Bootstrap: running installer as $TARGET_USER"
    run_as_target "$TARGET_HOME/dots/arch/install.sh" --boot-stack "$BOOT_STACK" "${INSTALL_ARGS[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
