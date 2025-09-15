function setup_lxd() {
    lxd init
    sudo lxc launch ubuntu:24.04 ubu
    sudo lxc config set ubu security.privileged true
    sudo lxc restart ubu
    # inside: sudo mount -o remount,rw /sys
    echo "root:100000:65536" | sudo tee /etc/subuid
    echo "root:100000:65536" | sudo tee /etc/subgid
    lxc config device add mycontainer mysharedfolder disk source=/home/user/shared path=/mnt/shared
}

function setup_systemdnspawn() {

    sudo systemctl enable --now systemd-networkd
    sudo systemctl enable --now systemd-resolved
    sudo debootstrap --arch=amd64 noble /var/lib/machines/ubuntu http://archive.ubuntu.com/ubuntu/
    sudo systemd-nspawn -D /var/lib/machines/ubuntu
    echo adduser archie
    echo usermod -aG sudo myuser

    echo passwd myuser
    sudo mkdir -p /etc/systemd/nspawn
    sudo tee /etc/systemd/nspawn/ubuntu.nspawn <<EOF
[Exec]
Boot=yes

[Network]
Host=yes
EOF
    echo sudo mount -o remount,rw /sys
}

function ubuntu() {
    sudo systemd-nspawn -D /var/lib/machines/ubuntu
}
