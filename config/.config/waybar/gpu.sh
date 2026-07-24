#!/usr/bin/env bash

GPU_HISTORY="${TMPDIR:-/tmp}/waybar_gpu"
SPARK_CHARS=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
MAX_HISTORY=12

spark_color() {
    if [[ $1 -ge 80 ]]; then
        printf '%s' '#f38ba8'
    elif [[ $1 -ge 60 ]]; then
        printf '%s' '#f9e2af'
    else
        printf '%s' '#a6e3a1'
    fi
}

if command -v nvidia-smi >/dev/null 2>&1; then
    IFS=',' read -r VALUE MEM_USED MEM_TOTAL TEMP < <(
        nvidia-smi --id=0 --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu \
            --format=csv,noheader,nounits 2>/dev/null
    )
    VALUE=${VALUE//[[:space:]]/}
    MEM_USED=${MEM_USED//[[:space:]]/}
    MEM_TOTAL=${MEM_TOTAL//[[:space:]]/}
    TEMP=${TEMP//[[:space:]]/}
    TOOLTIP="NVIDIA GPU: ${VALUE}% | VRAM: ${MEM_USED}/${MEM_TOTAL} MiB | ${TEMP} C"
elif command -v intel_gpu_top >/dev/null 2>&1; then
    SAMPLE=$(timeout -s INT -k 1 1.2 intel_gpu_top -J -s 500 2>/dev/null)
    # ponytail: use the busiest engine; summing parallel Intel engines can exceed 100%.
    VALUE=$(jq -r 'last | [.engines[]?.busy] | max // empty' <<<"$SAMPLE" 2>/dev/null)
    VALUE=${VALUE%.*}
    TOOLTIP="Intel GPU: ${VALUE:-unavailable}%"
else
    VALUE=''
    TOOLTIP='GPU telemetry unavailable'
fi

if [[ ! $VALUE =~ ^[0-9]+$ ]]; then
    printf '{"text":"GPU 󰢮 unavailable", "tooltip":"%s", "class":"unavailable"}\n' "$TOOLTIP"
    exit 0
fi

if [[ -f "$GPU_HISTORY" ]]; then
    mapfile -t HISTORY <"$GPU_HISTORY"
else
    HISTORY=()
fi
HISTORY+=("$VALUE")
[[ ${#HISTORY[@]} -gt $MAX_HISTORY ]] && HISTORY=("${HISTORY[@]: -$MAX_HISTORY}")
printf '%s\n' "${HISTORY[@]}" >"$GPU_HISTORY"

SPARK=''
for value in "${HISTORY[@]}"; do
    index=$((value * 7 / 100))
    ((index > 7)) && index=7
    color=$(spark_color "$value")
    SPARK+="<span foreground=\\\"${color}\\\">${SPARK_CHARS[$index]}</span>"
done

color=$(spark_color "$VALUE")
if ((VALUE >= 80)); then
    CLASS='critical'
elif ((VALUE >= 60)); then
    CLASS='warning'
else
    CLASS='normal'
fi

printf '{"text":"GPU 󰢮 <span foreground=\\\"%s\\\">%s</span> <span foreground=\\\"%s\\\">%s%%</span>", "tooltip":"%s", "class":"%s"}\n' \
    "$color" "$SPARK" "$color" "$VALUE" "$TOOLTIP" "$CLASS"
