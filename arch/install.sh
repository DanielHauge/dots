#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DOTS_LOC=${DOTS_LOC:-$(cd -- "$SCRIPT_DIR/.." && pwd)}
DRY_RUN=false
CHECK_ONLY=false
BOOT_STACK=''
DOCKER_GROUP_CHANGED=false
SUDO_KEEPALIVE_PID=''

usage() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run] [--check] [--boot-stack refind-uki]

Provision this Arch workstation after the base installation.

  --dry-run          Print changes without applying them.
  --check            Validate prerequisites without provisioning.
  --boot-stack NAME  Provision a boot stack (refind-uki).
  -h, --help         Show this help.
EOF
}

run() {
    if [[ "$DRY_RUN" == true ]]; then
        printf 'Would run:'
        printf ' %q' "$@"
        printf '\n'
        return
    fi

    "$@"
}

require_arch_user() {
    if ! command -v pacman >/dev/null 2>&1; then
        echo "This installer must run on an installed Arch system." >&2
        exit 1
    fi

    if ((EUID == 0)); then
        echo "Run this installer as the desktop user, not root." >&2
        exit 1
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        echo "sudo is required to provision system packages and services." >&2
        exit 1
    fi
}

preflight() {
    require_arch_user
    [[ -d "$DOTS_LOC/config/.config" ]] || { echo "Missing dotfiles in $DOTS_LOC/config." >&2; exit 1; }
    [[ -f "$SCRIPT_DIR/profiles/base.services" ]] || { echo "Missing service manifest: $SCRIPT_DIR/profiles/base.services" >&2; exit 1; }
    command -v git >/dev/null 2>&1 || { echo "git is required." >&2; exit 1; }
    if [[ "$CHECK_ONLY" == true ]]; then
        sudo -v
    fi

    if [[ "$BOOT_STACK" == refind-uki ]]; then
        [[ -d /sys/firmware/efi ]] || { echo "rEFInd/UKI provisioning requires UEFI boot." >&2; exit 1; }
        command -v findmnt >/dev/null 2>&1 || { echo "findmnt is required for EFI validation." >&2; exit 1; }
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
    trap '[[ -z "$SUDO_KEEPALIVE_PID" ]] || kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
}

phase() {
    local name=$1
    shift
    printf '\n== %s ==\n' "$name"
    if ! "$@"; then
        echo "Provisioning stopped during \"$name\". Fix the reported error, then rerun this command." >&2
        exit 1
    fi
}

ensure_paru() {
    local package=''
    local build_dir=''

    if command -v paru >/dev/null 2>&1 && paru --version >/dev/null 2>&1; then
        return
    fi

    run sudo pacman -Syu --needed --noconfirm base-devel git

    # A stale package can block makepkg from replacing a helper linked to an old libalpm ABI.
    for package in paru paru-bin; do
        if pacman -Q "$package" >/dev/null 2>&1; then
            run sudo pacman -Rns --noconfirm "$package"
        fi
    done

    build_dir=$(mktemp -d)
    (
        trap 'rm -rf -- "$build_dir"' EXIT
        run git clone https://aur.archlinux.org/paru.git "$build_dir/paru"
        if [[ "$DRY_RUN" == false ]]; then
            cd "$build_dir/paru"
            # Remove Rust build dependencies after paru is installed; rustup is the workstation toolchain.
            makepkg -si --rmdeps --noconfirm
        else
            printf 'Would run: (cd %q && makepkg -si --rmdeps --noconfirm)\n' "$build_dir/paru"
        fi
    )
}

ensure_oh_my_zsh() {
    local zsh_dir="$HOME/.oh-my-zsh"
    local plugin=''
    local repo=''

    if [[ ! -f "$zsh_dir/oh-my-zsh.sh" ]]; then
        [[ ! -e "$zsh_dir" ]] || { echo "Oh My Zsh directory is incomplete: $zsh_dir" >&2; return 1; }
        run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
    fi

    for plugin in zsh-syntax-highlighting zsh-autosuggestions; do
        repo="https://github.com/zsh-users/$plugin.git"
        [[ -d "$zsh_dir/custom/plugins/$plugin" ]] ||
            run git clone --depth=1 "$repo" "$zsh_dir/custom/plugins/$plugin"
    done
}

enable_service_file() {
    local service=''

    while IFS= read -r service; do
        [[ -z "$service" || "$service" == \#* ]] && continue
        run sudo systemctl enable "$service"
    done <"$SCRIPT_DIR/profiles/base.services"
}

configure_docker_group() {
    if ! getent group docker >/dev/null 2>&1; then
        return
    fi

    if id -nG "$USER" | tr ' ' '\n' | grep -Fxq docker; then
        return
    fi

    run sudo usermod -aG docker "$USER"
    DOCKER_GROUP_CHANGED=true
}

link_path() {
    local source=$1
    local target=$2

    if [[ -L "$target" && "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
        return
    fi

    run rm -rf -- "$target"
    run ln -s "$source" "$target"
}

deploy_dotfiles() {
    local dotfile=''
    local source=''
    local target=''

    run mkdir -p "$HOME/.config"
    shopt -s nullglob dotglob
    for source in "$DOTS_LOC"/config/.config/*; do
        dotfile=$(basename "$source")
        link_path "$source" "$HOME/.config/$dotfile"
    done
    shopt -u nullglob dotglob

    link_path "$DOTS_LOC/config/.gitconfig" "$HOME/.gitconfig"
    link_path "$DOTS_LOC/config/.zshrc" "$HOME/.zshrc"
}

print_summary() {
    echo "Provisioned the common Arch setup."
    if [[ "$DOCKER_GROUP_CHANGED" == true ]]; then
        echo "Sign out and back in before using Docker without sudo."
    fi
}

main() {
    while (($# > 0)); do
        case "$1" in
        --dry-run)
            DRY_RUN=true
            ;;
        --check)
            CHECK_ONLY=true
            ;;
        --boot-stack)
            (($# > 1)) || { echo "--boot-stack requires a name." >&2; exit 1; }
            [[ "$2" == refind-uki ]] || { echo "Unsupported boot stack: $2" >&2; exit 1; }
            BOOT_STACK=$2
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 1
            ;;
        esac
        shift
    done

    preflight
    if [[ "$CHECK_ONLY" == true ]]; then
        echo "Preflight passed. Run without --check to provision this system."
        return
    fi

    if [[ "$DRY_RUN" == false ]]; then
        start_sudo_keepalive
    fi
    phase "AUR helper" ensure_paru
    if [[ "$DRY_RUN" == true ]]; then
        phase "Package synchronization" "$SCRIPT_DIR/sync.sh" -y --dry-run
    else
        phase "Package synchronization" "$SCRIPT_DIR/sync.sh" -y
    fi
    phase "Oh My Zsh" ensure_oh_my_zsh
    if [[ "$BOOT_STACK" == refind-uki ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "Would provision rEFInd, UKIs, Plymouth, and the Tokyo Night SDDM theme."
        else
            phase "rEFInd and UKI boot stack" sudo "$SCRIPT_DIR/boot-refind-uki.sh"
        fi
    fi
    phase "System services" enable_service_file
    phase "Docker group" configure_docker_group
    phase "Dotfiles" deploy_dotfiles
    print_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
