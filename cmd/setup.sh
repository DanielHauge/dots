export PATH="$PATH:$DOTS_LOC/cmd/bin"
for fn_file in "$DOTS_LOC/cmd/fn/"*; do
    [ -e "$fn_file" ] && source "$fn_file"
done

source "$DOTS_LOC/cmd/aliases.sh"
