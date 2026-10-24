#!/usr/bin/env bash
# Mock-only regression checks. Usage: bash cmd/tests/cast-test.sh [bash|zsh]
set -euo pipefail

test_shell=$(command -v "${1:-bash}")
source_file=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../fn" && pwd)/cast
work=$(mktemp -d /tmp/opencode/cast-test.XXXXXX)
trap 'rm -rf -- "$work"' EXIT
mkdir "$work/bin" "$work/home"
export HOME="$work/home"
export CAST_TEST_WORK="$work"
for utility in awk tr grep sed rm; do
    ln -s "$(command -v "$utility")" "$work/bin/$utility"
done

cat >"$work/bin/script" <<'MOCK'
#!/bin/bash
printf '%s\n' "$@" >"$CAST_TEST_WORK/script.args"
[[ $# = 5 && $1 = -q && $2 = -e && $3 = -c && $5 = /dev/null ]] || exit 91
[[ $4 = 'stty cols 4096 rows 200 && timeout -s TERM -k 1s 12s go2tv -l' ]] || exit 92
if read -r _; then exit 93; fi
/bin/sh -c "$4"
MOCK
cat >"$work/bin/stty" <<'MOCK'
#!/bin/bash
[[ $* = 'cols 4096 rows 200' ]] || exit 94
exit "${STTY_EXIT:-0}"
MOCK
cat >"$work/bin/timeout" <<'MOCK'
#!/bin/bash
[[ $1 = -s && $2 = TERM && $3 = -k && $4 = 1s && $5 = 12s ]] || exit 95
shift 5
"$@" || exit "$?"
exit "${SCAN_EXIT:-124}"
MOCK
cat >"$work/bin/go2tv" <<'MOCK'
#!/bin/bash
if [[ $* = -l ]]; then
    printf 'discovered\n' >"$CAST_TEST_WORK/discovered"
    /bin/cat "$CAST_TEST_WORK/devices"
    exit "${DISCOVERY_EXIT:-0}"
fi
printf '%s\n' "$@" >"$CAST_TEST_WORK/cast.args"
if [[ ${5:-} = -s ]]; then
    /bin/cat "$6" >"$CAST_TEST_WORK/subtitles"
    printf '%s\n' "$6" >"$CAST_TEST_WORK/subtitle.path"
fi
MOCK
cat >"$work/bin/fzf" <<'MOCK'
#!/bin/bash
printf '%s\n' "$@" >"$CAST_TEST_WORK/fzf.args"
/bin/cat >"$CAST_TEST_WORK/choices"
case ${FZF_MODE:-second} in
    cancel) exit 130 ;;
    empty) exit 0 ;;
    second) sed -n '2p' "$CAST_TEST_WORK/choices" ;;
    *) sed -n '1p' "$CAST_TEST_WORK/choices" ;;
esac
MOCK
cat >"$work/bin/ffprobe" <<'MOCK'
#!/bin/bash
printf '%s\n' "$@" >"$CAST_TEST_WORK/probe.args"
if [[ ${SUBTITLES:-0} = 1 ]]; then printf '0\n'; fi
exit 0
MOCK
cat >"$work/bin/ffmpeg" <<'MOCK'
#!/bin/bash
printf '%s\n' "$@" >"$CAST_TEST_WORK/ffmpeg.args"
printf '%s\n' 1 '00:00:01,000 --> 00:00:02,000' '{\an8}Hello' >"${!#}"
MOCK
for mock in script stty timeout go2tv fzf ffprobe ffmpeg; do
    chmod +x "$work/bin/$mock"
done
video="$work/video with spaces.mkv"
touch "$video"
export TV='http://stale.invalid/device.xml'
export SCAN_EXIT=124 DISCOVERY_EXIT=0 STTY_EXIT=0 SUBTITLES=0 FZF_MODE=first

fail() { printf 'FAIL (%s): %s\n' "${1:-case}" "${2:-assertion}" >&2; exit 1; }
equal() { [[ $1 = "$2" ]] || fail "$case_name" "expected [$2], got [$1]"; }
absent() { [[ ! -e $work/$1 ]] || fail "$case_name" "unexpected $1"; }
reset_case() {
    case_name=$1
    rm -f "$work/"*.args "$work/choices" "$work/discovered" "$work/subtitles" "$work/subtitle.path"
    rm -rf -- "$HOME/.cast-selection"
    : >"$work/devices"
    export SCAN_EXIT=124 DISCOVERY_EXIT=0 STTY_EXIT=0 SUBTITLES=0 FZF_MODE=first
}
run_command() {
    result=0
    # The child shell expands its own positional arguments.
    # shellcheck disable=SC2016
    PATH="$work/bin" "$test_shell" -c '. "$1"; . "$2"; shift 2; "$@"' \
        cast-test "$source_file" "$source_file-select" "$@" >"$work/output" 2>&1 || result=$?
}
run_cast() { run_command cast "$@"; }
run_select() { run_command cast-select "$@"; }
failed_before_cast() {
    [[ $result != 0 ]] || fail "$case_name" 'expected failure'
    absent cast.args
    absent probe.args
}
one_tv() { printf '• Living [Room] TV DLNA [http://tv-one:1400/device.xml]\n' >"$work/devices"; }
two_tvs() {
    one_tv
    printf '• Bedroom TV Chromecast [https://tv-two:8009/device.xml]\n' >>"$work/devices"
}
check_target() {
    local expected
    printf -v expected '%s\n' -t "$1" -v "$video"
    equal "$(<"$work/cast.args")" "${expected%$'\n'}"
}

reset_case 'invalid arguments precede discovery'
run_cast
failed_before_cast
absent script.args
grep -q 'Usage: cast' "$work/output"
reset_case 'missing file precedes discovery'
run_cast "$work/missing"
failed_before_cast
absent script.args

for dependency in go2tv script timeout; do
    reset_case "missing $dependency"
    mv "$work/bin/$dependency" "$work/$dependency.saved"
    run_cast "$video"
    mv "$work/$dependency.saved" "$work/bin/$dependency"
    failed_before_cast
    grep -q "$dependency is required" "$work/output"
done

reset_case 'empty discovery'
run_cast "$video"
failed_before_cast
grep -q 'no TVs found' "$work/output"

reset_case 'no devices, diagnostics and truncated rows ignored'
printf '%s\n' 'No devices found: http://diagnostic/' \
    'error: • Not a TV DLNA [http://diagnostic/]' \
    '• Broken DLNA [http://truncated/' \
    '• Broken DLNA [http://truncated/…]' \
    '• Broken DLNA [http://truncated/...]' >"$work/devices"
run_cast "$video"
failed_before_cast
grep -q 'no TVs found' "$work/output"

reset_case 'sole URL, timeout 124, fzf required, stale TV variable ignored'
one_tv
run_cast "$video"
equal "$result" 0
check_target 'http://tv-one:1400/device.xml'
grep -Fxq "$video" "$work/probe.args"
[[ -e $work/fzf.args ]] || fail "$case_name" 'fzf not invoked'
equal "$(<"$HOME/.cast-selection")" 'http://tv-one:1400/device.xml'

reset_case 'clean discovery exit zero'
one_tv
export SCAN_EXIT=0
run_cast "$video"
equal "$result" 0
check_target 'http://tv-one:1400/device.xml'

reset_case 'ANSI OSC CR redraws deduplicate URLs and retain bracketed names'
export FZF_MODE=second
printf '\033]0;go2tv\007\033[?25l\033[32m• Living [Room] TV DLNA [http://tv-one:1400/device.xml]\033[0m\r\n\033[2K• Alternate Name DLNA [http://tv-one:1400/device.xml]\r\033]0;go2tv\033\\\033[1A• Living [Room] TV DLNA [http://tv-one:1400/device.xml]\r\n• Bedroom TV Chromecast [https://tv-two:8009/device.xml]\r\n' >"$work/devices"
run_cast "$video"
equal "$result" 0
check_target 'https://tv-two:8009/device.xml'
equal "$(<"$work/choices")" $'http://tv-one:1400/device.xml\tLiving [Room] TV DLNA\nhttps://tv-two:8009/device.xml\tBedroom TV Chromecast'
equal "$(<"$work/fzf.args")" $'--delimiter=\t\n--with-nth=2\n--prompt=Select TV: '

reset_case 'repeated sole URL is deduplicated and selected with fzf'
one_tv
one_row=$(<"$work/devices")
printf '%s\r\n%s\r\n' "$one_row" "$one_row" >"$work/devices"
run_cast "$video"
equal "$result" 0
equal "$(<"$work/choices")" $'http://tv-one:1400/device.xml\tLiving [Room] TV DLNA'
check_target 'http://tv-one:1400/device.xml'

for mode in cancel empty; do
    reset_case "selection $mode"
    two_tvs
    export FZF_MODE=$mode
    run_cast "$video"
    equal "$result" 0
    absent cast.args
    absent probe.args
done

reset_case 'multiple devices require fzf'
two_tvs
mv "$work/bin/fzf" "$work/fzf.saved"
run_cast "$video"
mv "$work/fzf.saved" "$work/bin/fzf"
failed_before_cast
grep -q 'fzf is required' "$work/output"

for code in 1 137; do
    reset_case "failed discovery $code rejects partial devices"
    one_tv
    export DISCOVERY_EXIT=$code
    run_cast "$video"
    failed_before_cast
    grep -q 'TV discovery failed' "$work/output"
done
reset_case 'stty failure stops discovery'
one_tv
export STTY_EXIT=1
run_cast "$video"
failed_before_cast
absent discovered
grep -q 'TV discovery failed' "$work/output"

reset_case 'missing ffprobe'
one_tv
mv "$work/bin/ffprobe" "$work/ffprobe.saved"
run_cast "$video"
mv "$work/ffprobe.saved" "$work/bin/ffprobe"
failed_before_cast
grep -q 'ffprobe is required' "$work/output"

reset_case 'selected TV with subtitles and spaced video'
two_tvs
export SUBTITLES=1 FZF_MODE=second
run_cast "$video"
equal "$result" 0
subs=$(<"$work/subtitle.path")
printf -v expected '%s\n' -t 'https://tv-two:8009/device.xml' -v "$video" -s "$subs"
equal "$(<"$work/cast.args")" "${expected%$'\n'}"
grep -Fxq "$video" "$work/ffmpeg.args"
grep -Fxq 'Hello' "$work/subtitles"
[[ ! -e $subs ]] || fail "$case_name" 'subtitle temporary file not removed'

reset_case 'missing ffmpeg for subtitle extraction'
one_tv
export SUBTITLES=1
mv "$work/bin/ffmpeg" "$work/ffmpeg.saved"
run_cast "$video"
mv "$work/ffmpeg.saved" "$work/bin/ffmpeg"
[[ $result != 0 ]] || fail "$case_name" 'expected failure'
absent cast.args
grep -q 'ffmpeg is required' "$work/output"

reset_case 'repeat processes reuse available saved URL without fzf executable'
two_tvs
export FZF_MODE=second
run_cast "$video"
equal "$result" 0
equal "$(<"$HOME/.cast-selection")" 'https://tv-two:8009/device.xml'
rm -f "$work/fzf.args" "$work/cast.args" "$work/discovered"
mv "$work/bin/fzf" "$work/fzf.saved"
run_cast "$video"
mv "$work/fzf.saved" "$work/bin/fzf"
equal "$result" 0
check_target 'https://tv-two:8009/device.xml'
absent fzf.args
[[ -e $work/discovered ]] || fail "$case_name" 'saved URL not checked against discovery'

reset_case 'sole saved available URL bypasses absent fzf'
one_tv
printf '%s\n' 'http://tv-one:1400/device.xml' >"$HOME/.cast-selection"
mv "$work/bin/fzf" "$work/fzf.saved"
run_cast "$video"
mv "$work/fzf.saved" "$work/bin/fzf"
equal "$result" 0
check_target 'http://tv-one:1400/device.xml'
absent fzf.args

reset_case 'stale saved URL is replaced by selected TV'
printf '%s\n' "$TV" >"$HOME/.cast-selection"
one_tv
run_cast "$video"
equal "$result" 0
check_target 'http://tv-one:1400/device.xml'
equal "$(<"$HOME/.cast-selection")" 'http://tv-one:1400/device.xml'
[[ -e $work/fzf.args ]] || fail "$case_name" 'fzf not invoked'

reset_case 'manual selection rejects arguments before discovery'
run_select unexpected
failed_before_cast
absent script.args
grep -q 'Usage: cast-select' "$work/output"

for devices in one_tv two_tvs; do
    reset_case "manual reselection with $devices and available saved TV"
    "$devices"
    printf '%s\n' 'http://tv-one:1400/device.xml' >"$HOME/.cast-selection"
    if [[ $devices = two_tvs ]]; then export FZF_MODE=second; fi
    mv "$work/bin/ffprobe" "$work/ffprobe.saved"
    mv "$work/bin/ffmpeg" "$work/ffmpeg.saved"
    run_select
    mv "$work/ffprobe.saved" "$work/bin/ffprobe"
    mv "$work/ffmpeg.saved" "$work/bin/ffmpeg"
    equal "$result" 0
    [[ -e $work/fzf.args ]] || fail "$case_name" 'fzf not invoked'
    if [[ $devices = two_tvs ]]; then
        equal "$(<"$HOME/.cast-selection")" 'https://tv-two:8009/device.xml'
    else
        equal "$(<"$HOME/.cast-selection")" 'http://tv-one:1400/device.xml'
    fi
    absent cast.args
    absent probe.args
    absent ffmpeg.args
done

for command in cast cast-select; do
    args=()
    if [[ $command = cast ]]; then args=("$video"); fi
    for mode in cancel empty; do
        for prior in none saved; do
            reset_case "$command selection $mode preserves $prior selection"
            one_tv
            if [[ $prior = saved ]]; then
                printf '%s\n' "$TV" >"$HOME/.cast-selection"
            fi
            export FZF_MODE=$mode
            run_command "$command" "${args[@]}"
            equal "$result" 0
            absent cast.args
            absent probe.args
            absent ffmpeg.args
            if [[ $prior = saved ]]; then
                equal "$(<"$HOME/.cast-selection")" "$TV"
            else
                [[ ! -e $HOME/.cast-selection ]] || fail "$case_name" 'selection created'
            fi
        done
    done
    for failure in empty discovery; do
        reset_case "$command $failure discovery preserves selection"
        printf '%s\n' "$TV" >"$HOME/.cast-selection"
        if [[ $failure = discovery ]]; then
            one_tv
            export DISCOVERY_EXIT=1
        fi
        run_command "$command" "${args[@]}"
        failed_before_cast
        absent fzf.args
        absent ffmpeg.args
        equal "$(<"$HOME/.cast-selection")" "$TV"
    done
    reset_case "$command save failure prevents media tools and playback"
    one_tv
    mkdir "$HOME/.cast-selection"
    run_command "$command" "${args[@]}"
    failed_before_cast
    absent ffmpeg.args
    grep -q 'could not save TV selection' "$work/output"
    [[ -d $HOME/.cast-selection ]] || fail "$case_name" 'selection directory replaced'

    reset_case "$command sole device requires fzf when no selection saved"
    one_tv
    mv "$work/bin/fzf" "$work/fzf.saved"
    run_command "$command" "${args[@]}"
    mv "$work/fzf.saved" "$work/bin/fzf"
    failed_before_cast
    grep -q 'fzf is required' "$work/output"
done

printf 'cast mock regressions passed (%s)\n' "${1:-bash}"
