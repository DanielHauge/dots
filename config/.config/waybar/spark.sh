#!/usr/bin/env bash
# ~/.config/waybar/scripts/spark.sh
# Usage: spark.sh cpu   OR   spark.sh mem

MODE="${1:-cpu}"
HISTORY_FILE="/tmp/waybar_spark_${MODE}"
SPARK_CHARS=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
MAX_HISTORY=12

COLOR_GREEN="#a6e3a1"
COLOR_YELLOW="#f9e2af"
COLOR_RED="#f38ba8"

spark_color() {
    local v=$1
    if [[ $v -ge 80 ]]; then
        echo "$COLOR_RED"
    elif [[ $v -ge 60 ]]; then
        echo "$COLOR_YELLOW"
    else
        echo "$COLOR_GREEN"
    fi
}

# --- sample the current value ---
if [[ "$MODE" == "cpu" ]]; then
    read -r _ u1 n1 s1 i1 w1 _ _ _ _ </proc/stat
    sleep 0.3
    read -r _ u2 n2 s2 i2 w2 _ _ _ _ </proc/stat
    idle1=$((i1 + w1))
    idle2=$((i2 + w2))
    total1=$((u1 + n1 + s1 + i1 + w1))
    total2=$((u2 + n2 + s2 + i2 + w2))
    diff_total=$((total2 - total1))
    diff_idle=$((idle2 - idle1))
    [[ $diff_total -eq 0 ]] && VALUE=0 || VALUE=$(((diff_total - diff_idle) * 100 / diff_total))
    ICON="󰻠"
    TOOLTIP="CPU: ${VALUE}%"
else
    MEM_TOTAL=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
    MEM_AVAIL=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
    MEM_USED=$((MEM_TOTAL - MEM_AVAIL))
    VALUE=$((MEM_USED * 100 / MEM_TOTAL))
    MEM_USED_GB=$(echo "scale=1; $MEM_USED / 1048576" | bc)
    MEM_TOTAL_GB=$(echo "scale=1; $MEM_TOTAL / 1048576" | bc)
    ICON="󰍛"
    TOOLTIP="Memory: ${MEM_USED_GB}G \/ ${MEM_TOTAL_GB}G (${VALUE}%)"
fi

# --- update rolling history ---
if [[ -f "$HISTORY_FILE" ]]; then
    mapfile -t HISTORY <"$HISTORY_FILE"
else
    HISTORY=()
fi
HISTORY+=("$VALUE")
[[ ${#HISTORY[@]} -gt $MAX_HISTORY ]] && HISTORY=("${HISTORY[@]: -$MAX_HISTORY}")
printf '%s\n' "${HISTORY[@]}" >"$HISTORY_FILE"

# --- build colored spark string (Pango markup per bar) ---
SPARK=""
for v in "${HISTORY[@]}"; do
    idx=$((v * 7 / 100))
    [[ $idx -lt 0 ]] && idx=0
    [[ $idx -gt 7 ]] && idx=7
    col=$(spark_color "$v")
    SPARK+="<span foreground=\\\"${col}\\\">${SPARK_CHARS[$idx]}</span>"
done

# --- class for CSS theming ---
if [[ $VALUE -ge 80 ]]; then
    CLASS="critical"
elif [[ $VALUE -ge 60 ]]; then
    CLASS="warning"
else
    CLASS="normal"
fi

# --- current value color for the percentage readout ---
VAL_COLOR=$(spark_color "$VALUE")

printf '{"text": "%s %s <span foreground=\\\"%s\\\">%s</span> <span foreground=\\\"%s\\\">%d%%</span>", "tooltip": "%s", "class": "%s"}\n' \
    "$MODE" \
    "$ICON" \
    "$VAL_COLOR" "$SPARK" \
    "$VAL_COLOR" "$VALUE" \
    "$TOOLTIP" \
    "$CLASS"
