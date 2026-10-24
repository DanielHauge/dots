# Throughput backends

Run `python3 ~/.config/waybar/throughput.py network` or `... disks` as a
continuous Waybar JSON script (no `interval`; use `hide-empty-text: true`).
Samples emit immediately and every two seconds, with decimal B/s, kB/s,
MB/s or GB/s. The first sample and counter resets show zero, not a spike.

Rate cells reserve three numeric columns and four unit columns in monospace,
including at idle, so normal rate/unit changes do not move neighboring text.
Numbers use 13px; quieter units/device names use 11px, with compact gaps.
Bar values keep one decimal below 10 and whole numbers above; tooltips retain
the extra precision. Rounded bar values promote units rather than overflow.
Receive/read uses blue, transmit/write mauve; idle values, units and device
labels are quieter. Arrows and R/W labels remain visible without color.
Rates cap at 999 GB/s on the bar (999.9 GB/s in tooltips).
Output uses trusted Pango markup (`escape: false`),
with dynamic names escaped in both labels and tooltips.

Network selects one lowest-metric IPv4 default-route interface, falling back
to IPv6; LAN traffic on that interface is included. Routes are rediscovered
each sample. Disconnected/missing devices hide and automatically reappear.

Disks default to the whole physical parent disk(s) of the actual `/` source,
not `/boot` or attached external storage. `WAYBAR_DISKS='sda nvme0n1'` selects
exact device names instead, with independent labeled read/write rates in one
module. Partitions such as `sda1` and `nvme0n1p2` are accepted. Names must match
`[A-Za-z0-9][A-Za-z0-9_-]*`; paths and other invalid entries are ignored,
duplicates removed, and an explicitly empty override selects nothing. Export
the variable into Waybar's environment before starting Waybar. Missing
selected disks are omitted; present idle disks show `0 B/s`.

Uses Python's standard library, Linux sysfs, `ip`, `findmnt`, and `lsblk`.
Root auto-detection needs a `/dev/`-backed source and physical `disk` ancestors;
overlay/network roots require an explicit override. Only the chosen default
route is measured (no aggregation of VPN/physical layers or policy-route
inference). A device replaced entirely between polls without an observed
absence or counter decrease cannot be distinguished from continued traffic.
GPU support remains NVIDIA/Intel only; unavailable telemetry emits empty text
without modifying history, and is retried on the next Waybar poll.

From this directory, run the isolated deterministic tests and syntax checks:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 test-throughput.py -v
bash test-gpu.sh
bash -n gpu.sh test-gpu.sh
shellcheck gpu.sh test-gpu.sh
python3 -c 'import ast, pathlib; [ast.parse(pathlib.Path(p).read_text(), filename=p) for p in ("throughput.py", "test-throughput.py")]'
```
