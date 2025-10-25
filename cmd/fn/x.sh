if command -v explorer.exe &>/dev/null; then
    function open_path() {
        # if on windows
        if command -v wslpath &>/dev/null; then
            windows_path=$(wslpath -w "$1")
            explorer.exe "$windows_path"
            return
        fi
        unix_path=$(realpath "$1")
        windows_path=$(echo "$unix_path" | sed 's/^\///' | sed 's/\//\\/g' | sed 's/^./\0:/')
        explorer.exe "$windows_path"
    }
    alias xdg-open='open_path'
    function open_url() {
        start firefox "$1"
    }
elif command -v xdg-open &>/dev/null; then
    alias open_path='xdg-open'
    alias open_url='xdg-open'
elif command -v gnome-open &>/dev/null; then
    alias open_path='gnome-open'
    alias open_url='gnome-open'
elif command -v kde-open &>/dev/null; then
    alias open_path='kde-open'
    alias open_url='kde-open'
elif command -v cygstart &>/dev/null; then
    alias open_path='cygstart'
    alias open_url='cygstart'
elif command -v start &>/dev/null; then
    alias open_path='start'
    alias open_url='start ""'
else
    echo "❌No suitable program found to open files❌"
fi

function x {
    if [ "$#" -eq 0 ]; then
        # Try read from standard in, but if there is no standard in, do something else
        if [ -t 0 ]; then
            p=$(fd | fzf)
            if [ -z "$p" ]; then
                return 1
            fi
            echo "Opening: $p"
            open_path "$p" &

            return 0
        fi
        while read -r line; do
            if echo "$line" | grep -q "http"; then
                echo "Web opening: $line"
                open_url "$line" &
                continue
            elif [ -e "$line" ]; then
                echo "Opening: $line"
                open_path "$line" &
            else
                # check if website with curl
                echo "Path does not exist: $line, opening as website"
            fi
        done

    fi
    for i in "$@"; do
        if echo "$i" | grep -q "http"; then
            echo "Web opening: $i"
            open_url "$i" &
            continue
        elif [ -e "$i" ]; then
            echo "Opening: $i"
            open_path "$i" &
        else
            # check if website with curl
            echo "Path does not exist: $i"
        fi
    done

}
