tmpdir=$(mktemp -d)
git clone https://aur.archlinux.org/paru.git "$tmpdir"
cd "$tmpdir"
makepkg -si --noconfirm
rm -rf "$tmpdir"
