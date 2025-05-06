while read -r pack; do
    if ! command -v "$pack"; then
        echo "Installing $pack..."
        paru -S "$pack" --noconfirm
    fi
done <aur-packages.txt
