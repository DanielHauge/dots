#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ESP=${ESP:-}

fail() {
    echo "rEFInd/UKI provisioning: $*" >&2
    exit 1
}

[[ ${EUID:-} -eq 0 ]] || fail "must run as root"
[[ -d /sys/firmware/efi ]] || fail "UEFI boot is required"
grep -qw archiso /proc/cmdline &&
    fail "must run after booting the installed system, not from the Arch ISO chroot"
if [[ -z "$ESP" ]]; then
    for candidate in /efi /boot /boot/efi; do
        if [[ $(findmnt -n -o FSTYPE --target "$candidate" 2>/dev/null || true) == vfat ]]; then
            ESP=$candidate
            break
        fi
    done
fi
[[ -n "$ESP" ]] || fail "could not find a mounted FAT EFI System Partition"
[[ $(findmnt -n -o FSTYPE --target "$ESP") == vfat ]] ||
    fail "$ESP must be the mounted FAT EFI System Partition"
findmnt --fstab --target "$ESP" >/dev/null 2>&1 ||
    fail "$ESP must have a persistent /etc/fstab entry"
efibootmgr -v >/dev/null || fail "cannot read UEFI NVRAM"

mkdir -p "$ESP/EFI/Linux"
mkdir -p /etc/mkinitcpio.conf.d
install -Dm644 "$SCRIPT_DIR/system/monogram/hood-mark.png" \
    /usr/share/workstation-identity/mark.png
install -Dm644 "$SCRIPT_DIR/system/monogram/hood-mark.png" \
    "$ESP/EFI/refind/assets/mark.png"
install -Dm644 "$ESP/EFI/refind/assets/mark.png" \
    /usr/share/plymouth/themes/tokyo-night/mark.png
convert -size 440x16 xc:'#172033' -fill '#00E5FF' -draw 'rectangle 4,4 435,11' \
    /usr/share/plymouth/themes/tokyo-night/progress-box.png
convert -size 432x8 xc:'#00E5FF' /usr/share/plymouth/themes/tokyo-night/progress-fill.png

cmdline=$(sed -E 's/(^| )BOOT_IMAGE=[^ ]+//g; s/[[:space:]]+/ /g; s/^ //; s/ $//' /proc/cmdline)
for parameter in quiet splash loglevel=3 rd.udev.log_level=3 systemd.show_status=auto vt.global_cursor_default=0; do
    [[ " $cmdline " == *" $parameter "* ]] || cmdline+=" $parameter"
done
printf '%s\n' "$cmdline" >/etc/kernel/cmdline

# Preserve the installed hook order, adding Plymouth directly after systemd or
# udev, before storage and filesystem hooks.
# shellcheck disable=SC1091
source /etc/mkinitcpio.conf
if [[ " ${HOOKS[*]} " != *" plymouth "* ]]; then
    updated_hooks=()
    insertion_hook=udev
    [[ " ${HOOKS[*]} " == *" systemd "* ]] && insertion_hook=systemd
    for hook in "${HOOKS[@]}"; do
        updated_hooks+=("$hook")
        [[ "$hook" == "$insertion_hook" ]] && updated_hooks+=(plymouth)
    done
    {
        printf 'HOOKS=('
        printf '%q ' "${updated_hooks[@]}"
        printf ')\n'
    } >/etc/mkinitcpio.conf.d/10-plymouth.conf
fi

configure_preset() {
    local name=$1
    local image=$2
    local preset=/etc/mkinitcpio.d/linux.preset

    if grep -q "^${name}_uki=" "$preset"; then
        sed -i -E "s|^${name}_uki=.*|${name}_uki=\"$image\"|" "$preset" ||
            fail "could not update ${name} UKI preset"
    else
        sed -i -E "s|^#${name}_uki=.*|${name}_uki=\"$image\"|" "$preset" ||
            fail "could not enable ${name} UKI preset"
    fi
}

configure_preset default "$ESP/EFI/Linux/arch-linux.efi"
configure_preset fallback "$ESP/EFI/Linux/arch-linux-fallback.efi"
if ! grep -Eq "^PRESETS=.*['\"]fallback['\"]" /etc/mkinitcpio.d/linux.preset; then
    sed -i -E "s/^PRESETS=.*/PRESETS=('default' 'fallback')/" /etc/mkinitcpio.d/linux.preset
fi
if ! grep -q '^fallback_options=' /etc/mkinitcpio.d/linux.preset; then
    sed -i -E 's|^#fallback_options=.*|fallback_options="-S autodetect"|' /etc/mkinitcpio.d/linux.preset
fi

install -Dm755 "$SCRIPT_DIR/system/greetd/update-issue" /usr/local/lib/workstation-identity/update-issue
install -Dm644 "$SCRIPT_DIR/system/greetd/update-issue.service" \
    /etc/systemd/system/workstation-identity-issue.service
install -Dm644 "$SCRIPT_DIR/system/greetd/config.toml" /etc/greetd/config.toml
install -Dm644 "$SCRIPT_DIR/system/plymouth/tokyo-night.plymouth" \
    /usr/share/plymouth/themes/tokyo-night/tokyo-night.plymouth
install -Dm644 "$SCRIPT_DIR/system/plymouth/tokyo-night.script" \
    /usr/share/plymouth/themes/tokyo-night/tokyo-night.script
printf '[Daemon]\nTheme=tokyo-night\n' >/etc/plymouth/plymouthd.conf

refind-install
install -Dm644 "$SCRIPT_DIR/system/refind/refind.conf" "$ESP/EFI/refind/refind.conf"
mkinitcpio -P
[[ -s "$ESP/EFI/Linux/arch-linux.efi" ]] || fail "default UKI was not generated"
[[ -s "$ESP/EFI/Linux/arch-linux-fallback.efi" ]] || fail "fallback UKI was not generated"

refind_id=$(efibootmgr | sed -n 's/^Boot\([0-9A-Fa-f]\{4\}\)\*.*rEFInd.*/\1/p' | head -n1)
[[ -n "$refind_id" ]] || fail "rEFInd EFI entry was not created"
current_order=$(efibootmgr | sed -n 's/^BootOrder: //p')
remaining_order=$(tr ',' '\n' <<<"$current_order" | { grep -Fvx "$refind_id" || true; } | paste -sd, -)
desired_order="$refind_id${remaining_order:+,$remaining_order}"
[[ "$current_order" == "$desired_order" ]] || efibootmgr -o "$desired_order"
if systemctl is-enabled --quiet sddm.service; then
    systemctl disable sddm.service
fi
systemctl enable workstation-identity-issue.service greetd.service

echo "rEFInd, UKIs, Plymouth, and tuigreet are ready. Reboot to test the new boot entry; GRUB remains available as fallback."
