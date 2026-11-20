#!/usr/bin/env bash
# Mock-only regression checks. Usage: bash cmd/tests/cast-test.sh [bash|zsh]
set -euo pipefail

test_shell=$(command -v "${1:-bash}")
source_file=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../fn" && pwd)/cast
work=$(mktemp -d /tmp/opencode/cast-test.XXXXXX)
trap 'rm -rf -- "$work"' EXIT
mkdir "$work/bin" "$work/home" "$work/tmp"
export HOME="$work/home"
export TMPDIR="$work/tmp"
export CAST_TEST_WORK="$work"
touch "$TMPDIR/unrelated"
cat >"$work/styled.ass" <<'ASS'
[Script Info]
ScriptType: v4.00+
PlayResX: 640
PlayResY: 360

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Gandhi Sans,78,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,2,0,2,10,10,10,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:01.00,0:00:02.00,Default,,0,0,0,,{\an8\bord3}A mage?
Dialogue: 0,0:00:03.00,0:00:04.00,Default,,0,0,0,,{\an7\pos(20,20)\p1}m 0 0 l 33 0 33 33 0 33{\p0}
ASS
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
    printf 'scan\n' >>"$CAST_TEST_WORK/events"
    printf 'discovered\n' >"$CAST_TEST_WORK/discovered"
    /bin/cat "$CAST_TEST_WORK/devices"
    exit "${DISCOVERY_EXIT:-0}"
fi
printf 'cast:%s\n' "$2" >>"$CAST_TEST_WORK/events"
printf '%s\n' "$@" >"$CAST_TEST_WORK/cast.args"
printf '%s\n' "$@" >>"$CAST_TEST_WORK/cast.calls"
printf '%s\n' "$4" >>"$CAST_TEST_WORK/video.paths"
if [[ $4 != "$CAST_TEST_WORK/video with spaces.mkv" ]]; then
    [[ -f $4 ]] || exit 97
    /bin/cat "$4" >"$CAST_TEST_WORK/remuxed.video"
fi
if [[ ${5:-} = -s ]]; then
    /bin/cat "$6" >"$CAST_TEST_WORK/subtitles" || exit 96
    printf '%s\n' "$6" >"$CAST_TEST_WORK/subtitle.path"
    printf '%s\n' "$6" >>"$CAST_TEST_WORK/subtitle.paths"
fi
if [[ $2 = "$TV" ]]; then exit "${SAVED_CAST_EXIT:-0}"; fi
exit "${CAST_EXIT:-0}"
MOCK
cat >"$work/bin/fzf" <<'MOCK'
#!/bin/bash
printf '%s\n' "$@" >"$CAST_TEST_WORK/fzf.args"
kind=tv
mode=${FZF_MODE:-second}
for arg in "$@"; do
    case $arg in
        '--prompt=Select audio: ') kind=audio; mode=${AUDIO_FZF_MODE:-$mode} ;;
        '--prompt=Select subtitles: ') kind=subtitle; mode=${SUBTITLE_FZF_MODE:-$mode} ;;
    esac
done
if [[ $kind = tv ]]; then
    printf 'select\n' >>"$CAST_TEST_WORK/events"
else
    printf 'select:%s\n' "$kind" >>"$CAST_TEST_WORK/events"
fi
/bin/cat >"$CAST_TEST_WORK/choices"
/bin/cp "$CAST_TEST_WORK/choices" "$CAST_TEST_WORK/$kind.choices"
printf '%s\n' "$@" >"$CAST_TEST_WORK/$kind.fzf.args"
case $mode in
    cancel) exit 130 ;;
    empty) exit 0 ;;
    second) /bin/sed -n '2p' "$CAST_TEST_WORK/choices" ;;
    *) /bin/sed -n '1p' "$CAST_TEST_WORK/choices" ;;
esac
MOCK
cat >"$work/bin/ffprobe" <<'MOCK'
#!/bin/bash
printf '%s\n' "$@" >"$CAST_TEST_WORK/probe.args"
printf 'probe\n' >>"$CAST_TEST_WORK/prep"
[[ $# = 7 && $1 = -v && $2 = error && $3 = -show_entries &&
    $4 = stream=index,codec_type,codec_name:stream_tags=language,title &&
    $5 = -of && $6 = $'compact=p=0:nk=0:escape=c:s=\'\t\'' ]] || exit 98
if [[ -f $CAST_TEST_WORK/tracks ]]; then
    /bin/cat "$CAST_TEST_WORK/tracks"
else
    printf 'index=0\tcodec_name=h264\tcodec_type=video\n'
    if [[ ${AUDIO:-0} = 1 ]]; then
        printf 'index=1\tcodec_name=aac\tcodec_type=audio\n'
    fi
    case ${SUBTITLES:-0} in
        0) ;;
        1) printf 'index=2\tcodec_name=subrip\tcodec_type=subtitle\n' ;;
        *) printf 'index=2\tcodec_name=%s\tcodec_type=subtitle\n' "$SUBTITLES" ;;
    esac
fi
exit "${PROBE_EXIT:-0}"
MOCK
cat >"$work/bin/ffmpeg" <<'MOCK'
#!/bin/bash
printf '%s\n' "$@" >"$CAST_TEST_WORK/ffmpeg.args"
if [[ " $* " = *' -c:v copy '* ]]; then
    printf '%s\n' "$@" >"$CAST_TEST_WORK/remux.args"
    printf 'remux\n' >>"$CAST_TEST_WORK/prep"
    printf 'selected video and audio\n' >"${!#}"
    exit "${REMUX_EXIT:-0}"
fi
printf '%s\n' "$@" >"$CAST_TEST_WORK/extract.args"
printf 'extract\n' >>"$CAST_TEST_WORK/prep"
if [[ " $* " = *' -c:s ass '* ]]; then
    /bin/cat "$CAST_TEST_WORK/styled.ass" >"${!#}"
else
/bin/cat >"${!#}" <<'SRT'
1
00:00:01,000 --> 00:00:02,000
{\an8}Hello

2
00:00:03,000 --> 00:00:04,000
<font face="Gandhi Sans" size="78">A mage?</font>

3
00:00:05,000 --> 00:00:06,000
<FONT>Upper</fOnT> <FoNt color="red">mixed</FONT>

4
00:00:07,000 --> 00:00:08,000
<door opens> <fontastic>stay</fontastic> 2 < 3 > 1
SRT
fi
exit "${FFMPEG_EXIT:-0}"
MOCK
mv_path=$(command -v mv)
mktemp_path=$(command -v mktemp)
# The generated mock expands these variables when it runs.
# shellcheck disable=SC2016
printf '#!/bin/bash\n[[ ${SAVE_EXIT:-0} = 0 ]] || exit "$SAVE_EXIT"\nexec %q "$@"\n' "$mv_path" >"$work/bin/mv"
printf '#!/bin/bash\nprintf "%%s\\n" "$@" >>"$CAST_TEST_WORK/temp.calls"\nexec %q "$@"\n' "$mktemp_path" >"$work/bin/mktemp"
for mock in script stty timeout go2tv fzf ffprobe ffmpeg mv mktemp; do
    chmod +x "$work/bin/$mock"
done
video="$work/video with spaces.mkv"
touch "$video"
export TV='http://stale.invalid/device.xml'
export SCAN_EXIT=124 DISCOVERY_EXIT=0 STTY_EXIT=0 SUBTITLES=0 FZF_MODE=first
export SAVED_CAST_EXIT=0 CAST_EXIT=0 PROBE_EXIT=0 FFMPEG_EXIT=0 SAVE_EXIT=0
export CAST_SELECT_SPY=0

fail() { printf 'FAIL (%s): %s\n' "${1:-case}" "${2:-assertion}" >&2; exit 1; }
equal() { [[ $1 = "$2" ]] || fail "$case_name" "expected [$2], got [$1]"; }
absent() { [[ ! -e $work/$1 ]] || fail "$case_name" "unexpected $1"; }
reset_case() {
    case_name=$1
    rm -f "$work/"*.args "$work/choices" "$work/discovered" "$work/subtitles" "$work/subtitle.path" \
        "$work/subtitle.paths" "$work/events" "$work/prep" "$work/cast.calls" \
        "$work/tracks" "$work/"*.choices "$work/video.paths" "$work/remuxed.video" "$work/temp.calls"
    rm -rf -- "$HOME/.cast-selection"
    : >"$work/devices"
    export SCAN_EXIT=124 DISCOVERY_EXIT=0 STTY_EXIT=0 SUBTITLES=0 FZF_MODE=first
    export SAVED_CAST_EXIT=0 CAST_EXIT=0 PROBE_EXIT=0 FFMPEG_EXIT=0 SAVE_EXIT=0
    export CAST_SELECT_SPY=0
    export AUDIO=0 REMUX_EXIT=0
    unset AUDIO_FZF_MODE SUBTITLE_FZF_MODE
}
run_command() {
    result=0
    # The child shell expands its own positional arguments.
    # shellcheck disable=SC2016
    PATH="$work/bin" "$test_shell" -c '
        . "$1"; . "$2"; shift 2
        if [ "$CAST_SELECT_SPY" = 1 ]; then
            eval "$(typeset -f cast-select | sed "1s/cast-select/_cast_select_original/")"
            function cast-select() {
                printf "cast-select\n" >>"$CAST_TEST_WORK/events"
                _cast_select_original "$@"
            }
        fi
        "$@"' \
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
equal "$(<"$work/subtitles")" $'1\n00:00:01,000 --> 00:00:02,000\nHello\n\n2\n00:00:03,000 --> 00:00:04,000\nA mage?\n\n3\n00:00:05,000 --> 00:00:06,000\nUpper mixed\n\n4\n00:00:07,000 --> 00:00:08,000\n<door opens> <fontastic>stay</fontastic> 2 < 3 > 1'
[[ ! -e ${subs%/*} ]] || fail "$case_name" 'subtitle temporary directory not removed'

for codec in ass ssa; do
    reset_case "$codec preserves styled subtitles without text cleanup"
    printf '%s\n' "$TV" >"$HOME/.cast-selection"
    export SUBTITLES=$codec
    mv "$work/bin/sed" "$work/sed.saved"
    run_cast "$video"
    mv "$work/sed.saved" "$work/bin/sed"
    equal "$result" 0
    absent discovered
    subs=$(<"$work/subtitle.path")
    [[ $subs = "$TMPDIR"/cast.*/subtitles.ass ]] || fail "$case_name" 'expected private ASS path'
    cmp -s "$work/styled.ass" "$work/subtitles" || fail "$case_name" 'ASS content changed'
    printf -v expected '%s\n' -t "$TV" -v "$video" -s "$subs" -tc -burn-subtitles
    equal "$(<"$work/cast.args")" "${expected%$'\n'}"
    printf -v expected '%s\n' -hide_banner -loglevel error -i "$video" -map 0:2 -c:s ass -y "$subs"
    equal "$(<"$work/ffmpeg.args")" "${expected%$'\n'}"
    printf -v expected '%s\n' -v error -show_entries stream=index,codec_type,codec_name:stream_tags=language,title -of $'compact=p=0:nk=0:escape=c:s=\'\t\'' "$video"
    equal "$(<"$work/probe.args")" "${expected%$'\n'}"
    grep -Fq 'Casting with rendered subtitles (live transcoding)...' "$work/output"
    [[ ! -e ${subs%/*} ]] || fail "$case_name" 'ASS temporary directory not removed'
done

reset_case 'missing ffmpeg for subtitle extraction'
one_tv
export SUBTITLES=1
mv "$work/bin/ffmpeg" "$work/ffmpeg.saved"
run_cast "$video"
mv "$work/ffmpeg.saved" "$work/bin/ffmpeg"
[[ $result != 0 ]] || fail "$case_name" 'expected failure'
absent cast.args
grep -q 'ffmpeg is required' "$work/output"

reset_case 'repeat processes reuse saved URL without scan dependencies or scan membership'
two_tvs
export FZF_MODE=second
run_cast "$video"
equal "$result" 0
equal "$(<"$HOME/.cast-selection")" 'https://tv-two:8009/device.xml'
rm -f "$work/fzf.args" "$work/cast.args" "$work/discovered" "$work/script.args" "$work/events"
one_tv
for dependency in script timeout fzf; do
    mv "$work/bin/$dependency" "$work/$dependency.saved"
done
run_cast "$video"
for dependency in script timeout fzf; do
    mv "$work/$dependency.saved" "$work/bin/$dependency"
done
equal "$result" 0
check_target 'https://tv-two:8009/device.xml'
absent fzf.args
absent discovered
absent script.args
equal "$(<"$work/events")" 'cast:https://tv-two:8009/device.xml'

reset_case 'sole saved available URL bypasses absent fzf'
one_tv
printf '%s\n' 'http://tv-one:1400/device.xml' >"$HOME/.cast-selection"
mv "$work/bin/fzf" "$work/fzf.saved"
run_cast "$video"
mv "$work/fzf.saved" "$work/bin/fzf"
equal "$result" 0
check_target 'http://tv-one:1400/device.xml'
absent fzf.args
absent script.args
absent discovered

reset_case 'stale saved URL is replaced by selected TV'
printf '%s\n' "$TV" >"$HOME/.cast-selection"
export SAVED_CAST_EXIT=1
one_tv
run_cast "$video"
equal "$result" 0
check_target 'http://tv-one:1400/device.xml'
equal "$(<"$HOME/.cast-selection")" 'http://tv-one:1400/device.xml'
[[ -e $work/fzf.args ]] || fail "$case_name" 'fzf not invoked'
equal "$(<"$work/events")" $'cast:http://stale.invalid/device.xml\nscan\nselect\ncast:http://tv-one:1400/device.xml'
grep -q 'saved TV attempt failed (exit 1)' "$work/output"

for prior in none saved; do
    reset_case "cast invokes public cast-select with $prior selection"
    one_tv
    export CAST_SELECT_SPY=1 SAVED_CAST_EXIT=1
    if [[ $prior = saved ]]; then printf '%s\n' "$TV" >"$HOME/.cast-selection"; fi
    run_cast "$video"
    equal "$result" 0
    expected=$'cast-select\nscan\nselect\ncast:http://tv-one:1400/device.xml'
    if [[ $prior = saved ]]; then expected=$'cast:http://stale.invalid/device.xml\n'"$expected"; fi
    equal "$(<"$work/events")" "$expected"
    equal "$(<"$HOME/.cast-selection")" 'http://tv-one:1400/device.xml'
    check_target 'http://tv-one:1400/device.xml'
done

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
    [[ -e $work/discovered ]] || fail "$case_name" 'discovery not invoked'
    if [[ $devices = two_tvs ]]; then
        equal "$(<"$HOME/.cast-selection")" 'https://tv-two:8009/device.xml'
    else
        equal "$(<"$HOME/.cast-selection")" 'http://tv-one:1400/device.xml'
    fi
    grep -Fxq "$(<"$HOME/.cast-selection")" "$work/output"
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
                export SAVED_CAST_EXIT=1
            fi
            export FZF_MODE=$mode
            run_command "$command" "${args[@]}"
            equal "$result" 0
            if [[ $command = cast && $prior = saved ]]; then
                equal "$(<"$work/events")" $'cast:http://stale.invalid/device.xml\nscan\nselect'
            else
                absent cast.args
                absent probe.args
            fi
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
        export SAVED_CAST_EXIT=1
        if [[ $failure = discovery ]]; then
            one_tv
            export DISCOVERY_EXIT=1
        fi
        run_command "$command" "${args[@]}"
        if [[ $command = cast ]]; then
            [[ $result != 0 ]] || fail "$case_name" 'expected failure'
            equal "$(<"$work/events")" $'cast:http://stale.invalid/device.xml\nscan'
        else
            failed_before_cast
        fi
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

reset_case 'empty saved selection uses normal discovery'
: >"$HOME/.cast-selection"
one_tv
run_cast "$video"
equal "$result" 0
equal "$(<"$work/events")" $'scan\nselect\ncast:http://tv-one:1400/device.xml'
equal "$(<"$HOME/.cast-selection")" 'http://tv-one:1400/device.xml'

reset_case 'saved selection without trailing newline is reused directly'
printf '%s' "$TV" >"$HOME/.cast-selection"
run_cast "$video"
equal "$result" 0
check_target "$TV"
absent script.args
equal "$(<"$HOME/.cast-selection")" "$TV"

reset_case 'unreadable saved selection uses normal discovery'
printf '%s\n' "$TV" >"$HOME/.cast-selection"
chmod 000 "$HOME/.cast-selection"
if [[ ! -r $HOME/.cast-selection ]]; then
    one_tv
    run_cast "$video"
    equal "$result" 0
    equal "$(<"$work/events")" $'scan\nselect\ncast:http://tv-one:1400/device.xml'
else
    printf 'SKIP (%s): current user can read mode-000 files\n' "$case_name"
fi
chmod 600 "$HOME/.cast-selection"

for subtitles in 1 ass; do
for failure in file go2tv ffprobe probe ffmpeg extraction mktemp; do
    reset_case "saved selection local $failure failure never scans or casts with subtitles=$subtitles"
    printf '%s\n' "$TV" >"$HOME/.cast-selection"
    args=("$video")
    case $failure in
        file) args=("$work/missing") ;;
        go2tv|ffprobe|ffmpeg|mktemp) mv "$work/bin/$failure" "$work/$failure.saved" ;;
        probe) export PROBE_EXIT=3 ;;
        extraction) export FFMPEG_EXIT=4 ;;
    esac
    if [[ $failure = ffmpeg || $failure = extraction || $failure = mktemp ]]; then export SUBTITLES=$subtitles; fi
    run_cast "${args[@]}"
    case $failure in
        go2tv|ffprobe|ffmpeg|mktemp) mv "$work/$failure.saved" "$work/bin/$failure" ;;
    esac
    [[ $result != 0 ]] || fail "$case_name" 'expected failure'
    absent cast.args
    absent script.args
    absent discovered
    equal "$(<"$HOME/.cast-selection")" "$TV"
    if [[ $failure = probe ]]; then equal "$result" 3; fi
    if [[ $failure = extraction ]]; then
        subs=$(<"$work/ffmpeg.args")
        subs=${subs##*$'\n'}
        [[ ! -e ${subs%/*} ]] || fail "$case_name" 'partial subtitle directory not removed'
    fi
done
done

for command in cast cast-select; do
    reset_case "$command failed replacement save preserves saved file"
    printf '%s\n' "$TV" >"$HOME/.cast-selection"
    one_tv
    export SAVED_CAST_EXIT=1 SAVE_EXIT=1
    args=()
    if [[ $command = cast ]]; then args=("$video"); fi
    run_command "$command" "${args[@]}"
    [[ $result != 0 ]] || fail "$case_name" 'expected failure'
    equal "$(<"$HOME/.cast-selection")" "$TV"
    grep -q 'could not save TV selection' "$work/output"
    if [[ $command = cast ]]; then
        equal "$(<"$work/events")" $'cast:http://stale.invalid/device.xml\nscan\nselect'
    else
        absent cast.args
    fi
    if compgen -G "$HOME/.cast-selection.*" >/dev/null; then
        fail "$case_name" 'selection temporary file not removed'
    fi
done

for subtitles in 0 1 ass ssa; do
    for prior in none saved; do
        for code in 0 7; do
            reset_case "$prior selection final exit $code with subtitles=$subtitles"
            one_tv
            export SUBTITLES=$subtitles CAST_EXIT=$code SAVED_CAST_EXIT=1
            if [[ $prior = saved ]]; then printf '%s\n' "$TV" >"$HOME/.cast-selection"; fi
            run_cast "$video"
            equal "$result" "$code"
            if [[ $prior = saved ]]; then
                equal "$(<"$work/events")" $'cast:http://stale.invalid/device.xml\nscan\nselect\ncast:http://tv-one:1400/device.xml'
            else
                equal "$(<"$work/events")" $'scan\nselect\ncast:http://tv-one:1400/device.xml'
            fi
            equal "$(<"$HOME/.cast-selection")" 'http://tv-one:1400/device.xml'
            if [[ $subtitles != 0 ]]; then
                equal "$(<"$work/prep")" $'probe\nextract'
                subs=$(<"$work/subtitle.path")
                render_args=()
                if [[ $subtitles = ass || $subtitles = ssa ]]; then
                    cmp -s "$work/styled.ass" "$work/subtitles" || fail "$case_name" 'ASS content changed'
                    render_args=(-tc -burn-subtitles)
                else
                    grep -Fxq 'Hello' "$work/subtitles"
                fi
                printf -v expected '%s\n' -t 'http://tv-one:1400/device.xml' -v "$video" -s "$subs" "${render_args[@]}"
                equal "$(<"$work/cast.args")" "${expected%$'\n'}"
                if [[ $prior = saved ]]; then
                    printf -v first_call '%s\n' -t "$TV" -v "$video" -s "$subs" "${render_args[@]}"
                    expected="$first_call$expected"
                fi
                equal "$(<"$work/cast.calls")" "${expected%$'\n'}"
                [[ ! -e ${subs%/*} ]] || fail "$case_name" 'subtitle directory not removed after final cast'
                if [[ $prior = saved ]]; then
                    equal "$(<"$work/subtitle.paths")" "$subs"$'\n'"$subs"
                fi
            else
                equal "$(<"$work/prep")" 'probe'
                absent ffmpeg.args
                check_target 'http://tv-one:1400/device.xml'
            fi
        done
    done
done

for subtitles in 1 ass; do
for failure in cancel discovery save dependency; do
    reset_case "saved failure cleans prepared subtitles after fallback $failure with subtitles=$subtitles"
    printf '%s\n' "$TV" >"$HOME/.cast-selection"
    one_tv
    export SUBTITLES=$subtitles SAVED_CAST_EXIT=1
    case $failure in
        cancel) export FZF_MODE=cancel ;;
        discovery) export DISCOVERY_EXIT=1 ;;
        save) export SAVE_EXIT=1 ;;
        dependency) mv "$work/bin/script" "$work/script.saved" ;;
    esac
    run_cast "$video"
    if [[ $failure = dependency ]]; then mv "$work/script.saved" "$work/bin/script"; fi
    if [[ $failure = cancel ]]; then
        equal "$result" 0
    else
        [[ $result != 0 ]] || fail "$case_name" 'expected failure'
    fi
    equal "$(grep -c '^cast:' "$work/events")" 1
    equal "$(<"$work/prep")" $'probe\nextract'
    equal "$(<"$HOME/.cast-selection")" "$TV"
    subs=$(<"$work/subtitle.path")
    [[ ! -e ${subs%/*} ]] || fail "$case_name" 'subtitle directory not removed after fallback stopped'
done
done

no_media_temp() {
    if compgen -G "$TMPDIR/cast.*" >/dev/null; then
        fail "$case_name" 'media temporary directory left behind'
    fi
}
multi_audio() {
    printf '%s\n' $'index=0\tcodec_name=h264\tcodec_type=video' \
        $'index=3\tcodec_name=aac\tcodec_type=audio' \
        $'tag:title=Director, guest = commentary | "mix"\\\tpart\\nnext \\\\\tcodec_type=audio\tindex=8\ttag:language=eng\tcodec_name=ac3' >"$work/tracks"
}
multi_subtitles() {
    printf '%s\n' $'index=5\tcodec_name=subrip\tcodec_type=subtitle\ttag:language=fra' >>"$work/tracks"
    printf 'tag:title=Signs, songs = special | cut\tindex=11\tcodec_type=subtitle\tcodec_name=%s\n' "$1" >>"$work/tracks"
}
check_audio_choices() {
    equal "$(<"$work/audio.choices")" $'3\t3: aac\n8\t8: ac3 [eng] Director, guest = commentary | "mix"\\tpart\\nnext \\\\'
    equal "$(<"$work/audio.fzf.args")" $'--delimiter=\t\n--with-nth=2\n--prompt=Select audio: '
}
check_remux() {
    local prepared=$1 expected
    printf -v expected '%s\n' -hide_banner -loglevel error -i "$video" \
        -map 0:v:0 -map 0:8 -c:v copy -c:a copy -sn -dn -y "$prepared"
    equal "$(<"$work/remux.args")" "${expected%$'\n'}"
    equal "$(<"$work/remuxed.video")" 'selected video and audio'
}

for audio in 0 1; do
    for subtitles in 0 1; do
        reset_case "zero/sole audio=$audio subtitles=$subtitles needs no picker or remux"
        printf '%s\n' "$TV" >"$HOME/.cast-selection"
        export AUDIO=$audio SUBTITLES=$subtitles
        mv "$work/bin/fzf" "$work/fzf.saved"
        if [[ $subtitles = 0 ]]; then mv "$work/bin/ffmpeg" "$work/ffmpeg.saved"; fi
        run_cast "$video"
        mv "$work/fzf.saved" "$work/bin/fzf"
        if [[ $subtitles = 0 ]]; then mv "$work/ffmpeg.saved" "$work/bin/ffmpeg"; fi
        equal "$result" 0
        absent fzf.args
        absent remux.args
        equal "$(<"$work/video.paths")" "$video"
        no_media_temp
    done
done

reset_case 'sole non-first absolute subtitle index with absent metadata is automatic'
printf '%s\n' "$TV" >"$HOME/.cast-selection"
printf '%s\n' $'index=0\tcodec_type=video\tcodec_name=h264' \
    $'codec_type=subtitle\tindex=7\tcodec_name=subrip' >"$work/tracks"
run_cast "$video"
equal "$result" 0
absent fzf.args
subs=$(<"$work/subtitle.path")
printf -v expected '%s\n' -hide_banner -loglevel error -i "$video" -map 0:7 -c:s srt -y "$subs"
equal "$(<"$work/extract.args")" "${expected%$'\n'}"
no_media_temp

for codec in subrip ass ssa; do
    reset_case "multiple subtitles choose absolute index and preserve $codec"
    printf '%s\n' "$TV" >"$HOME/.cast-selection"
    : >"$work/tracks"
    multi_subtitles "$codec"
    export SUBTITLE_FZF_MODE=second
    run_cast "$video"
    equal "$result" 0
    absent remux.args
    absent audio.fzf.args
    equal "$(<"$work/subtitle.choices")" $'5\t5: subrip [fra]\n11\t11: '"$codec"' Signs, songs = special | cut'
    equal "$(<"$work/subtitle.fzf.args")" $'--delimiter=\t\n--with-nth=2\n--prompt=Select subtitles: '
    subs=$(<"$work/subtitle.path")
    out_codec=srt
    render_args=()
    if [[ $codec != subrip ]]; then
        out_codec=ass
        render_args=(-tc -burn-subtitles)
        cmp -s "$work/styled.ass" "$work/subtitles" || fail "$case_name" 'selected ASS/SSA content changed'
    fi
    printf -v expected '%s\n' -hide_banner -loglevel error -i "$video" -map 0:11 -c:s "$out_codec" -y "$subs"
    equal "$(<"$work/extract.args")" "${expected%$'\n'}"
    printf -v expected '%s\n' -t "$TV" -v "$video" -s "$subs" "${render_args[@]}"
    equal "$(<"$work/cast.args")" "${expected%$'\n'}"
    no_media_temp
done

for subtitles in none subrip ass; do
    for retry in no success failure cancel empty discovery save dependency; do
        reset_case "multi-audio with $subtitles subtitles, saved TV retry=$retry"
        printf '%s\n' "$TV" >"$HOME/.cast-selection"
        multi_audio
        if [[ $subtitles != none ]]; then multi_subtitles "$subtitles"; fi
        export AUDIO_FZF_MODE=second SUBTITLE_FZF_MODE=second
        one_tv
        if [[ $retry != no ]]; then export SAVED_CAST_EXIT=6; fi
        case $retry in
            failure) export CAST_EXIT=7 ;;
            cancel|empty) export FZF_MODE=$retry ;;
            discovery) export DISCOVERY_EXIT=1 ;;
            save) export SAVE_EXIT=1 ;;
            dependency) mv "$work/bin/script" "$work/script.saved" ;;
        esac
        run_cast "$video"
        if [[ $retry = dependency ]]; then mv "$work/script.saved" "$work/bin/script"; fi
        case $retry in
            failure) equal "$result" 7 ;;
            discovery|save|dependency) [[ $result != 0 ]] || fail "$case_name" 'expected fallback failure' ;;
            *) equal "$result" 0 ;;
        esac
        check_audio_choices
        prepared=$(<"$work/video.paths")
        prepared=${prepared%%$'\n'*}
        [[ $prepared = "$TMPDIR"/cast.*/video.mkv ]] || fail "$case_name" 'expected private remux path'
        check_remux "$prepared"
        expected_prep=$'probe\nremux'
        if [[ $subtitles != none ]]; then expected_prep+=$'\nextract'; else absent extract.args; fi
        equal "$(<"$work/prep")" "$expected_prep"
        if [[ $retry = success || $retry = failure ]]; then
            equal "$(<"$work/video.paths")" "$prepared"$'\n'"$prepared"
            if [[ $subtitles != none ]]; then
                subs=$(<"$work/subtitle.path")
                equal "$(<"$work/subtitle.paths")" "$subs"$'\n'"$subs"
            fi
        else
            equal "$(<"$work/video.paths")" "$prepared"
        fi
        no_media_temp
    done
done

for kind in audio subtitle; do
    for mode in cancel empty missing; do
        reset_case "$kind picker $mode stops before any media preparation"
        printf '%s\n' "$TV" >"$HOME/.cast-selection"
        multi_audio
        multi_subtitles ass
        export AUDIO_FZF_MODE=second SUBTITLE_FZF_MODE=second
        if [[ $kind = subtitle && $mode = missing ]]; then
            # One audio stream bypasses its picker, so fzf is needed for subtitles only.
            printf '%s\n' $'index=3\tcodec_name=aac\tcodec_type=audio' >"$work/tracks"
            multi_subtitles ass
        fi
        if [[ $mode = missing ]]; then
            mv "$work/bin/fzf" "$work/fzf.saved"
        elif [[ $kind = audio ]]; then
            export AUDIO_FZF_MODE=$mode
        else
            export SUBTITLE_FZF_MODE=$mode
        fi
        run_cast "$video"
        if [[ $mode = missing ]]; then
            mv "$work/fzf.saved" "$work/bin/fzf"
            [[ $result != 0 ]] || fail "$case_name" 'expected missing fzf failure'
            grep -Fq "fzf is required to select a $kind track" "$work/output"
        else
            equal "$result" 0
        fi
        equal "$(<"$work/prep")" probe
        absent temp.calls
        absent ffmpeg.args
        absent cast.args
        absent script.args
        no_media_temp
    done
done

for failure in ffmpeg mktemp remux extraction cleanup; do
    reset_case "multi-audio local $failure failure cleans all prepared media and never retries TV"
    printf '%s\n' "$TV" >"$HOME/.cast-selection"
    multi_audio
    multi_subtitles subrip
    export AUDIO_FZF_MODE=second SUBTITLE_FZF_MODE=second
    case $failure in
        ffmpeg|mktemp) mv "$work/bin/$failure" "$work/$failure.saved" ;;
        remux) export REMUX_EXIT=9 ;;
        extraction) export FFMPEG_EXIT=8 ;;
        cleanup) mv "$work/bin/sed" "$work/sed.saved" ;;
    esac
    run_cast "$video"
    case $failure in
        ffmpeg|mktemp) mv "$work/$failure.saved" "$work/bin/$failure" ;;
        cleanup) mv "$work/sed.saved" "$work/bin/sed" ;;
    esac
    [[ $result != 0 ]] || fail "$case_name" 'expected preparation failure'
    absent cast.args
    absent script.args
    if [[ $failure = remux ]]; then
        equal "$(<"$work/prep")" $'probe\nremux'
        absent extract.args
    fi
    no_media_temp
done

[[ -f $TMPDIR/unrelated ]] || fail 'cleanup' 'unrelated temporary file removed'
printf 'cast mock regressions passed (%s)\n' "${1:-bash}"
