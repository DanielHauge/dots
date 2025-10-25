export PATH="$PATH:$DOTS_LOC/cmd/bin"
for fn_file in "$DOTS_LOC/cmd/fn/"*.sh; do
    [ -e "$fn_file" ] && source "$fn_file"
done
