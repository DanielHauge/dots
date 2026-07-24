#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TMPDIR=$(mktemp -d)
trap 'rm -rf -- "$TMPDIR"' EXIT

printf '%s\n' '#!/usr/bin/env bash' \
    "printf '%s\\n' '67, 1024, 4096, 54'" >"$TMPDIR/nvidia-smi"
chmod +x "$TMPDIR/nvidia-smi"

output=$(PATH="$TMPDIR:$PATH" "$SCRIPT_DIR/gpu.sh")
jq -e '.class == "warning" and (.text | contains("67%"))' <<<"$output" >/dev/null
