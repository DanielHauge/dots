function dots-install() {
    # if windows run install in windows
    if [ -n "$WINDIR" ]; then
        echo "Windows detected"
        $DOTS_LOC/win/install.sh
        return
    fi
    # if ubuntu
    if command -v apt-get &>/dev/null; then
        echo "Ubuntu detected"
        sudo $DOTS_LOC/ubuntu/install.sh
        return
    fi

    if command -v pacman &>/dev/null; then
        echo "Arch detected"
        $DOTS_LOC/arch/install.sh
        return
    fi

    echo "Unsupported OS detected"

}
