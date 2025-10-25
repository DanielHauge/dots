function mkfn {
    if [ $# -ne 1 ]; then
        echo "Usage: mkfn <function_name>"
        return 1
    fi
    if [[ ! $1 =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
        echo "Error: Function name must start with a letter or underscore and contain only letters, numbers, underscores, and dashes."
        return 1
    fi
    if command -v "$1" >/dev/null 2>&1 || declare -f "$1" >/dev/null 2>&1; then
        if [ -f "$DOTS_LOC/cmd/fn/$1.sh" ]; then
            :
        else
            echo "Error: Function name '$1' conflicts with an existing command or function."
            return 1
        fi
    fi

    fileloc=$DOTS_LOC/cmd/fn/$1.sh
    if [ ! -f "$fileloc" ]; then
        echo -e "function $1 {\n    if [ \$# -ne 1 ]; then\n        echo \"Usage: $1 <arg1>\"\n        return 1\n    fi\n    # TODO: Implement function logic here\n}\n" >"$fileloc"
        chmod +x "$fileloc"
    fi
    ${EDITOR:-nvim} "$fileloc"
    source "$fileloc"
}
