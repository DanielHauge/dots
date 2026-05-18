#!/usr/bin/env bash
# ~/.config/waybar/scripts/gpu.sh

GPU_HISTORY="/tmp/waybar_gpu"
VRAM_HISTORY="/tmp/waybar_gpu_mem"

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

# ----------------------------------------
# query nvidia
# ----------------------------------------

IFS=',' read -r GPU_UTIL MEM_USED MEM_TOTAL TEMP <<< \
    $(nvidia-smi \
        --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu \
        --format=csv,noheader,nounits)

GPU_UTIL=$(echo "$GPU_UTIL" | xargs)
MEM_USED=$(echo "$MEM_USED" | xargs)
MEM_TOTAL=$(echo "$MEM_TOTAL" | xargs)
TEMP=$(echo "$TEMP" | xargs)

VRAM_UTIL=$((MEM_USED * 100 / MEM_TOTAL))
VRAM_USED_GB=$(awk "BEGIN {printf \"%.1f\", $MEM_USED/1024}")
VRAM_TOTAL_GB=$(awk "BEGIN {printf \"%.1f\", $MEM_TOTAL/1024}")

# ----------------------------------------
# history helper
# ----------------------------------------

update_history() {
    local file="$1"
    local value="$2"

    if [[ -f "$file" ]]; then
        mapfile -t HISTORY <"$file"
    else
        HISTORY=()
    fi

    HISTORY+=("$value")

    [[ ${#HISTORY[@]} -gt $MAX_HISTORY ]] &&
        HISTORY=("${HISTORY[@]: -$MAX_HISTORY}")

    printf '%s\n' "${HISTORY[@]}" >"$file"
}

build_spark() {
    local result=""

    for v in "${HISTORY[@]}"; do
        idx=$((v * 7 / 100))

        [[ $idx -lt 0 ]] && idx=0
        [[ $idx -gt 7 ]] && idx=7

        col=$(spark_color "$v")

        result+="<span foreground=\\\"${col}\\\">${SPARK_CHARS[$idx]}</span>"
    done

    echo "$result"
}

# ----------------------------------------
# gpu spark
# ----------------------------------------

update_history "$GPU_HISTORY" "$GPU_UTIL"
GPU_SPARK=$(build_spark)

# ----------------------------------------
# vram spark
# ----------------------------------------

update_history "$VRAM_HISTORY" "$VRAM_UTIL"
VRAM_SPARK=$(build_spark)

GPU_COLOR=$(spark_color "$GPU_UTIL")
VRAM_COLOR=$(spark_color "$VRAM_UTIL")

# ----------------------------------------
# output
# ----------------------------------------

printf '{"text":"gpu 󰢮 <span foreground=\\\"%s\\\">%s</span> <span foreground=\\\"%s\\\">%s%%</span> 󰍛 <span foreground=\\\"%s\\\">(%sG/%sG)</span> <span foreground=\\\"%s\\\">%s%%</span>","tooltip":"%s°C","class":"normal"}\n' \
    "$GPU_COLOR" \
    "$GPU_SPARK" \
    "$GPU_COLOR" \
    "$GPU_UTIL" \
    "$VRAM_COLOR" \
    "$VRAM_USED_GB" \
    "$VRAM_TOTAL_GB" \
    "$VRAM_COLOR" \
    "$VRAM_UTIL" \
    "$TEMP"
