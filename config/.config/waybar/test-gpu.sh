#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/waybar-gpu-test.XXXXXX")
trap 'rm -rf -- "$TEST_ROOT"' EXIT
export TMPDIR="$TEST_ROOT"
mkdir "$TMPDIR/bin"
export PATH="$TMPDIR/bin:$PATH"

# Keep the sample selector literal for the generated mock to evaluate.
# shellcheck disable=SC2016
printf '%s\n' '#!/usr/bin/env bash' \
    'case ${GPU_TEST_SAMPLE:-available} in' \
    '  unavailable) exit 1 ;;' \
    '  malformed) printf "N/A, N/A, N/A, N/A\n" ;;' \
    '  failed-output) printf "67, 1024, 4096, 54\n"; exit 1 ;;' \
    '  recovered) printf "25, 512, 4096, 40\n" ;;' \
    '  *) printf "67, 1024, 4096, 54\n" ;;' \
    'esac' >"$TMPDIR/bin/nvidia-smi"
chmod +x "$TMPDIR/bin/nvidia-smi"

output=$("$SCRIPT_DIR/gpu.sh")
jq -e '.class == "warning" and (.text | contains("67%"))
    and (.text | contains("#f9e2af")) and (.tooltip | contains("1024/4096 MiB"))' <<<"$output" >/dev/null
[[ $(<"$TMPDIR/waybar_gpu") == 67 ]]

for sample in unavailable malformed failed-output; do
    output=$(GPU_TEST_SAMPLE="$sample" "$SCRIPT_DIR/gpu.sh")
    jq -e '.class == "unavailable" and .text == ""' <<<"$output" >/dev/null
    [[ $(<"$TMPDIR/waybar_gpu") == 67 ]]
done

output=$(GPU_TEST_SAMPLE=recovered "$SCRIPT_DIR/gpu.sh")
jq -e '.class == "normal" and (.text | contains("25%"))
    and (.text | contains("#a6e3a1")) and (.text | contains("#f9e2af"))' <<<"$output" >/dev/null
mapfile -t history <"$TMPDIR/waybar_gpu"
[[ ${#history[@]} == 2 && ${history[0]} == 67 && ${history[1]} == 25 ]]
printf '%s\n' 'GPU success, unavailable hiding, and recovery tests passed (isolated history).'
