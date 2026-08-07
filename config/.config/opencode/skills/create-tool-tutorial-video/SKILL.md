---
name: create-tool-tutorial-video
description: Turn a raw screen recording into a polished narrated software or tool tutorial. Use when an agent must inspect a screen recording, explain the UI workflow, write and synthesize narration with Kokoro TTS, verify pronunciation, synchronize narration to edited screen actions, add captions or visual emphasis, and render a reproducible tutorial video with code-driven tools such as FFmpeg and Remotion.
---

# Create a tool tutorial video

Produce a clear, accurate tutorial from a raw screen recording. Treat the recording as source material, not a fixed timeline. Build narration and visuals as independently editable segments, then synchronize them in an explicit edit plan.

## Operating principles

- Preserve factual accuracy. Describe only actions and outcomes supported by the recording or user context; mark uncertain UI interpretations.
- Preserve the raw recording. Write generated files to a separate project directory and never overwrite source media.
- Prefer reproducible code and declarative data over manual editor state.
- Use stable segment IDs across analysis, narration, audio, captions, and the edit plan.
- Generate narration per segment, not as one long audio file, so individual lines can be revised and regenerated.
- Keep narration timing flexible until speech has been synthesized and measured.
- Prefer changing the visuals to fit natural speech. Do not unnaturally rush narration merely to match the raw recording.
- Ask only for information that materially changes the tutorial. Continue with documented defaults when the user accepts best effort.
- Never publish or upload the result unless explicitly requested.

## Default toolchain

Use the tools already available in the environment when they satisfy the requirements. Otherwise prefer:

- `ffprobe` for media metadata and duration inspection.
- `ffmpeg` for frame extraction, trimming, concatenation, speed changes, freeze frames, audio mixing, loudness normalization, and final encoding.
- Kokoro TTS CLI for speech synthesis. Inspect `kokoro-tts --help`, `kokoro --help`, or the installed wrapper before constructing commands; do not assume a specific package's flags.
- Remotion for reusable composition, captions, callouts, zooms, title cards, pointer emphasis, and branded layouts.
- An available speech recognizer for transcript-based TTS checks.

Use a pure FFmpeg pipeline when the edit only needs cuts, timing changes, audio, and simple text. Use the FFmpeg + Remotion hybrid when the tutorial benefits from animated captions, callouts, zooms, branding, or reusable visual components. Do not introduce Remotion solely to concatenate clips.

## Project contract

Create or reuse a project directory with this logical structure:

```text
tutorial-project/
├── source/
│   └── recording.ext
├── analysis/
│   ├── media.json
│   ├── recording-analysis.md
│   └── contact-sheets/
├── narration/
│   ├── brief.md
│   ├── script.md
│   ├── pronunciation.yaml
│   └── review.md
├── audio/
│   ├── segments/
│   └── manifest.json
├── edit/
│   ├── timeline.json
│   └── decisions.md
├── captions/
│   └── captions.srt
├── remotion/
├── renders/
│   ├── preview.mp4
│   └── final.mp4
└── qa/
    └── report.md
```

Adapt names to the repository when conventions already exist. Keep generated and temporary media out of version control unless the user requests otherwise.

## Workflow

### 1. Inspect inputs and establish the brief

Locate the source recording and inspect it with `ffprobe`. Record duration, dimensions, frame rate, codecs, audio streams, and rotation metadata in `analysis/media.json`.

Collect any context already provided:

- intended audience and assumed knowledge;
- tutorial objective and desired takeaway;
- product, feature, and workflow names;
- desired tone, language, voice, pace, and approximate duration;
- required branding, aspect ratio, resolution, captions, and output format;
- steps to emphasize, omit, obscure, or correct.

If the narration objective is missing, ask one compact question offering these paths:

1. explain the visible workflow as a best-effort tutorial;
2. create a goal-oriented tutorial for an audience the user names;
3. wait for a supplied outline or script.

If the user chooses best effort or cannot respond, infer the likely objective from the recording, state the assumption in `narration/brief.md`, and continue.

Do not block on cosmetic preferences. Default to concise instructional narration, a neutral professional tone, the source aspect ratio, readable captions, and 1080p output when the source supports it.

### 2. Analyze the recording

Extract representative frames and contact sheets without modifying the source. Combine fixed-interval sampling with denser sampling around scene changes or likely UI transitions. Inspect the visual evidence in chronological order.

Identify observable events such as:

- page, tab, modal, or panel changes;
- clicks, selections, text entry, scrolling, dragging, and keyboard-driven actions;
- loading, success, error, confirmation, and result states;
- important cursor movement or focus changes;
- idle time, mistakes, retries, sensitive content, and irrelevant detours;
- moments needing zoom, freeze, callout, crop, blur, or replacement.

Create `analysis/recording-analysis.md` with:

1. recording summary;
2. inferred tutorial goal and confidence;
3. ordered event table;
4. ambiguities and facts requiring confirmation;
5. proposed omissions and visual enhancements.

Use this event table:

| Event ID | Source range | Visible action | Visible result | Tutorial significance | Confidence | Edit note |
| -------- | ------------ | -------------- | -------------- | --------------------- | ---------- | --------- |

Use source timestamps only as evidence locations. Do not treat them as final output timing.

### 3. Design the narrative

Create `narration/brief.md` before drafting prose. Define the audience, promise, start state, end state, terminology, tone, and desired depth.

Structure the tutorial around learner intent rather than narrating every cursor movement:

1. establish what the viewer will accomplish;
2. explain prerequisites or current state only when necessary;
3. group visible actions into meaningful steps;
4. explain why important choices matter;
5. confirm the result;
6. close with the next useful action, if appropriate.

Write `narration/script.md` as atomic segments. Use this structure for every segment:

```markdown
## N001 — Outcome

- Purpose: State what the viewer will accomplish.
- Visual events: E001
- On-screen emphasis: title card or result preview
- Narration: In this tutorial, we'll configure ...
- Pronunciation notes: none
- Delivery: confident, medium pace
```

Keep each segment focused on one visual idea. Prefer short, speakable sentences and contractions appropriate to the chosen tone. Avoid redundant phrases such as “as you can see,” literal cursor narration, unexplained jargon, and claims not visible in the source.

At normal instructional pace, estimate roughly 130–160 spoken words per minute, but measure synthesized audio instead of relying on the estimate for final timing.

### 4. Prepare pronunciation and synthesize speech

Discover the installed Kokoro CLI interface and available voices. Record the selected executable, voice, language, speed, sample rate, and relevant version information in `audio/manifest.json`.

Maintain `narration/pronunciation.yaml` as the source of truth for substitutions. Each entry should retain the written form and the exact TTS input form:

```yaml
terms:
  - written: PostgreSQL
    spoken: post-gres-Q-L
    reason: Preferred product pronunciation
```

Do not change viewer-facing captions merely to influence pronunciation. Apply pronunciation substitutions only to the TTS input derived from each narration segment.

Synthesize one lossless WAV file per segment into `audio/segments/<segment-id>.wav`. Record the script hash, TTS input, voice settings, output path, and measured duration for every segment in `audio/manifest.json`. Regenerate only changed or failed segments.

Leave short natural padding around segment audio where useful, but control meaningful pauses in the edit timeline rather than by inserting large amounts of silence into WAV files.

### 5. Review narration audio

Review every generated segment before editing the final timeline.

Use all available evidence:

- transcribe the synthesized audio and compare it with the intended narration;
- check names, acronyms, numbers, URLs, code, and technical terms explicitly;
- inspect clipping, leading or trailing truncation, excessive silence, and abnormal duration;
- listen when audio playback or human review is available.

Do not claim that transcription alone proves correct pronunciation or pleasant delivery. Mark pronunciation and prosody as requiring audible review when no capable reviewer is available.

For a failed segment:

1. update its entry in `pronunciation.yaml` or revise the sentence for speech;
2. regenerate only that segment;
3. repeat the review;
4. preserve the readable original wording for captions where appropriate.

Document results in `narration/review.md`, including segment ID, issue, change, regeneration count, and final status.

### 6. Build the edit plan

After audio durations are known, create `edit/timeline.json`. Make it the single source of truth for synchronization. Each segment must map narration to one or more source ranges and declare its visual treatment.

Use a schema equivalent to:

```json
{
  "version": 1,
  "fps": 30,
  "width": 1920,
  "height": 1080,
  "segments": [
    {
      "id": "N001",
      "audio": "audio/segments/N001.wav",
      "visuals": [
        {
          "sourceStart": 12.4,
          "sourceEnd": 18.9,
          "speed": 1.0,
          "freezeTail": 0.8
        }
      ],
      "leadIn": 0.2,
      "leadOut": 0.35,
      "overlays": [],
      "transition": "cut"
    }
  ]
}
```

Validate the actual schema in code. Reject missing media, invalid ranges, non-positive speeds, overlapping output segments that are not intentional, and output dimensions incompatible with the composition.

Synchronize in this order:

1. remove mistakes, waiting, dead time, and irrelevant actions;
2. choose the minimum visual material needed for each narration segment;
3. trim or accelerate low-information motion;
4. slow important interactions modestly;
5. freeze a stable UI state when explanation needs more time;
6. split or rewrite narration when the visual would otherwise feel unnaturally slow;
7. use recreated title cards, diagrams, or clean screenshots only when the recording cannot support the explanation.

Avoid rapid speed changes, excessive zooming, decorative transitions, and constant cursor chasing. Favor cuts, short dissolves when context changes, stable framing, and enough dwell time to understand the UI.

### 7. Implement the code-driven edit

Use FFmpeg preprocessing for operations that are simpler and more deterministic at the media layer:

- exact trims and concatenation;
- variable-speed source sections;
- freeze frames;
- crop, scale, pad, blur, and audio normalization;
- codec normalization for reliable composition.

Use Remotion components for presentation-layer behavior:

- title and section cards;
- animated captions;
- callouts, highlights, arrows, and click indicators;
- controlled pan and zoom;
- branded backgrounds, frames, and end cards.

Drive both layers from `edit/timeline.json`. Do not duplicate timing constants throughout source code. Cache deterministic intermediate clips, and invalidate them when their source range or transform settings change.

Keep the original UI legible. Use restrained zooms, maintain consistent margins, avoid covering the active control with captions, and redact secrets or personal data throughout every frame in which they appear.

### 8. Generate captions

Generate captions from the approved narration text and measured segment timing, not from an unrelated transcript of the raw recording. Preserve readable product spelling even when the TTS input uses phonetic substitutions.

Create `captions/captions.srt` and, when using styled captions, derive display cues from the same timing data. Keep cues short, break at natural phrase boundaries, and ensure sufficient reading time.

### 9. Render and validate

Render a low-cost preview before the final output. Inspect at least the start, every edit boundary, every overlay, every pronunciation-sensitive segment, and the ending.

Validate:

- narration matches the visible action and does not anticipate it confusingly;
- pacing feels intentional and important states remain visible long enough;
- there are no black frames, frozen mistakes, broken transitions, or missing media;
- captions match narration and remain inside safe areas;
- zooms and callouts point to the correct controls;
- redactions persist through movement and transitions;
- speech is intelligible and not clipped;
- music, when requested, remains subordinate to narration;
- final duration, resolution, frame rate, codecs, and audio streams are correct.

Normalize final narration loudness consistently and prevent true-peak clipping. Do not invent a universal loudness target when the destination platform or user has specified one.

Write `qa/report.md` with pass/fail status, commands executed, output metadata, known limitations, and any items requiring human review. Render the final file only after blocking issues are resolved or explicitly accepted.

## Checkpoints requiring user input

Pause for the user only when a decision would materially change meaning, privacy, or substantial work, including:

- the recording's purpose cannot be inferred reliably;
- visible behavior conflicts with the supplied explanation;
- sensitive information may need redaction;
- product terminology or pronunciation remains ambiguous;
- the user must choose between substantially different audiences or tutorial scopes;
- a destructive overwrite, upload, or publication would occur.

Do not pause merely to ask about font, minor transition style, or other reversible defaults.

## Completion report

Return:

1. the final or preview video path;
2. the narration script and analysis paths;
3. a concise summary of edits and assumptions;
4. the QA result and unresolved human-review items;
5. the exact command needed to reproduce the final render.

Never report a successful render without checking that the output exists, is non-empty, and has valid media metadata.
