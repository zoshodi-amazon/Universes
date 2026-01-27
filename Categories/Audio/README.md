# Audio/Video Pipeline - Filetype Transformation Calculus

## Core Thesis

Audio/video production is filetype transformation. Every operation is a morphism between codec spaces. Pipelines compose via monadic sequencing through the 5 orthogonal categories.

---

## Directory Structure

```
Categories/Audio/
├── README.md
├── Types/
│   ├── Inputs/
│   │   └── StorageIO/          # Local media storage (audio/, video/, images/)
│   └── Outputs/
│       └── StorageIO/          # Processed output storage
└── Monads/
    └── LocalIO/
        ├── Preamble/           # Inspection + catalog
        ├── Context/            # Conversion + fetch
        ├── Space/              # Stream manipulation
        ├── Time/               # Temporal operations
        └── Transform/          # Filters/effects
```

---

## Filetype Taxonomy

### Raw Formats (Uncompressed)
```
Audio: pcm, s16le, f32le
Video: yuv420p, rgb24, rgba
```

### Containers (Muxed Streams)
```
mp4, mkv, avi, mov, webm
```

### Audio Codecs
```
Lossless: wav, flac, alac
Lossy:    mp3, aac, opus, vorbis
```

### Video Codecs
```
Modern:  h264, h265 (hevc), vp9, av1
Legacy:  mpeg4, h263
```

---

## Operation Space (Category-Theoretic)

### Preamble: Inspection (f^* - Pull)
**Purpose**: Query metadata without transformation + catalog local storage

```
Probe    : File → Metadata
Streams  : File → [Stream]
Format   : File → Container × Codec
Duration : File → Time
Catalog  : StorageIO → [File]
```

**Operations**:
- Metadata extraction (codec, bitrate, resolution)
- Stream enumeration (audio/video/subtitle tracks)
- Format detection
- List available media in StorageIO
- Show public domain sources

### Context: Format Conversion (Codec Morphisms)
**Purpose**: Container remux, codec transcoding + fetch from remote sources

```
Remux     : Container₁ → Container₂  (preserve codec)
Transcode : Codec₁ → Codec₂          (change encoding)
Fetch     : URL → StorageIO          (download media)
```

**Operations**:
- Container remux: mp4 ↔ mkv ↔ avi (no re-encode)
- Audio transcode: wav → mp3, flac → opus
- Video transcode: h264 → h265, vp9 → av1
- Fetch from URL to StorageIO (audio/video/images)
- Fetch from Internet Archive

### Space: Stream Manipulation (Spatial Decomposition)
**Purpose**: Extract/merge independent streams

```
Extract : File → Audio ⊕ Video ⊕ Subtitles
Merge   : Audio ⊗ Video → File
Select  : File → Stream[i]
```

**Operations**:
- Extract audio from video
- Extract video without audio
- Merge separate audio/video files
- Multi-track handling

### Time: Temporal Operations (Sequential Composition)
**Purpose**: Manipulate timeline

```
Trim   : File × [Start, End] → File
Concat : File₁ ⊕ File₂ → File
Sync   : Audio × Video × Offset → File
Speed  : File × Rate → File
```

**Operations**:
- Cut/trim segments
- Concatenate files
- Audio/video sync adjustment
- Speed up/slow down

### Transform: Filters (Endomorphisms)
**Purpose**: Apply effects within codec space

```
AudioFilter : Audio → Audio  (volume, eq, normalize)
VideoFilter : Video → Video  (scale, crop, overlay)
Chain       : Filter₁ ∘ Filter₂ ∘ ... ∘ Filterₙ
```

**Operations**:
- Audio: volume, normalize, eq, reverb, noise reduction
- Video: scale, crop, rotate, overlay, color correction
- Filter chains (compose multiple effects)

---

## Monadic Composition Examples

### Example 1: Extract Audio → Process → Export
```
mp4 --[Space/extract]--> wav --[Transform/normalize]--> wav --[Context/transcode]--> mp3
```

**Commands**:
```bash
just Space/extract input.mp4 audio.wav
just Transform/audio-normalize audio.wav normalized.wav
just Context/audio-encode normalized.wav output.mp3
```

### Example 2: Video Overlay with Audio Mix
```
video1.mp4 --[Space/extract]--> video1_v.mp4 + video1_a.wav
video2.mp4 --[Space/extract]--> video2_v.mp4 + video2_a.wav

video1_v.mp4 + video2_v.mp4 --[Transform/overlay]--> composite.mp4
video1_a.wav + video2_a.wav --[Transform/mix]--> mixed.wav

composite.mp4 + mixed.wav --[Space/merge]--> final.mp4
```

### Example 3: Multi-Clip Edit with Sync
```
clip1.mp4 --[Time/trim]--> clip1_cut.mp4
clip2.mp4 --[Time/trim]--> clip2_cut.mp4
clip3.mp4 --[Time/trim]--> clip3_cut.mp4

[clip1_cut, clip2_cut, clip3_cut] --[Time/concat]--> sequence.mp4
sequence.mp4 + audio.wav --[Time/sync]--> final.mp4
```

### Example 4: Format Conversion Pipeline
```
avi --[Context/remux]--> mkv --[Context/transcode]--> h265.mkv --[Transform/scale]--> 1080p.mkv
```

---

## Transformation Algebra

### Homomorphisms (Structure-Preserving)
```
Remux: Preserve codec, change container
  mp4[h264] → mkv[h264]  (no quality loss)
```

### Isomorphisms (Lossless Bidirectional)
```
wav ↔ flac  (lossless compression)
pcm ↔ wav   (raw ↔ container)
```

### Lossy Morphisms (Irreversible)
```
wav → mp3   (lossy compression, no inverse)
h264 → h265 (re-encode, quality degradation)
```

### Functorial Composition
```
F : Container₁ → Container₂
G : Codec₁ → Codec₂

G ∘ F : (Container₁, Codec₁) → (Container₂, Codec₂)
```

---

## End-to-End Workflow: Podcast Production

### Input
- `raw_audio.wav` (48kHz, stereo, uncompressed)
- `intro.mp3` (music)
- `outro.mp3` (music)

### Pipeline
```
1. [Preamble/probe]     raw_audio.wav → verify format
2. [Transform/normalize] raw_audio.wav → normalized.wav
3. [Time/trim]          intro.mp3 → intro_5s.mp3
4. [Time/trim]          outro.mp3 → outro_5s.mp3
5. [Time/concat]        [intro_5s, normalized, outro_5s] → full.wav
6. [Transform/eq]       full.wav → eq.wav
7. [Context/encode]     eq.wav → final.mp3 (192kbps)
8. [Preamble/probe]     final.mp3 → verify output
```

### Commands
```bash
just Preamble/probe raw_audio.wav
just Transform/audio-normalize raw_audio.wav normalized.wav
just Time/trim intro.mp3 intro_5s.mp3 0 5
just Time/trim outro.mp3 outro_5s.mp3 0 5
just Time/concat-audio intro_5s.mp3 normalized.wav outro_5s.mp3 full.wav
just Transform/audio-eq full.wav eq.wav
just Context/audio-encode eq.wav final.mp3 192k
just Preamble/probe final.mp3
```

---

## End-to-End Workflow Example: YouTube Video Edit

### Scenario
Create a highlight reel from a raw recording with intro/outro music, color correction, and final export.

### Input Files
- `raw_recording.mp4` (1080p, 30fps, 10 minutes)
- `intro_music.mp3` (5 seconds)
- `outro_music.mp3` (5 seconds)
- `logo.png` (watermark overlay)

### Pipeline Steps

```bash
# 1. Inspect raw recording
cd Categories/Audio/Monads/LocalIO
just Preamble/probe raw_recording.mp4
just Preamble/video-info raw_recording.mp4

# 2. Extract interesting segments (3 clips)
just Time/trim raw_recording.mp4 clip1.mp4 30 45      # 30s-75s
just Time/trim raw_recording.mp4 clip2.mp4 120 60     # 2m-3m
just Time/trim raw_recording.mp4 clip3.mp4 480 30     # 8m-8m30s

# 3. Apply color correction to each clip
just Transform/video-brightness-contrast clip1.mp4 clip1_color.mp4 0.1 1.2
just Transform/video-brightness-contrast clip2.mp4 clip2_color.mp4 0.1 1.2
just Transform/video-brightness-contrast clip3.mp4 clip3_color.mp4 0.1 1.2

# 4. Add logo watermark to each clip
just Transform/video-overlay clip1_color.mp4 logo.png clip1_final.mp4 10 10
just Transform/video-overlay clip2_color.mp4 logo.png clip2_final.mp4 10 10
just Transform/video-overlay clip3_color.mp4 logo.png clip3_final.mp4 10 10

# 5. Create concat list and merge clips
just Time/create-concat-list clips.txt "clip1_final.mp4 clip2_final.mp4 clip3_final.mp4"
just Time/concat clips.txt video_sequence.mp4

# 6. Extract audio from video sequence
just Space/extract-audio video_sequence.mp4 video_audio.wav

# 7. Normalize audio
just Transform/audio-normalize video_audio.wav video_audio_norm.wav

# 8. Add intro music (fade in)
just Transform/audio-fade intro_music.mp3 intro_fade.mp3 1 0

# 9. Add outro music (fade out)
just Transform/audio-fade outro_music.mp3 outro_fade.mp3 0 2

# 10. Concatenate audio: intro + main + outro
just Time/concat-audio intro_fade.mp3 video_audio_norm.wav temp1.wav
just Time/concat-audio temp1.wav outro_fade.mp3 final_audio.wav

# 11. Merge final audio with video
just Space/merge-av video_sequence.mp4 final_audio.wav final_with_audio.mp4

# 12. Transcode to H265 for smaller file size
just Context/video-encode-h265 final_with_audio.mp4 final_output.mp4 28

# 13. Verify final output
just Preamble/probe final_output.mp4
just Preamble/duration final_output.mp4
```

### Transformation Flow Diagram

```
raw_recording.mp4
    │
    ├─[Time/trim]──> clip1.mp4 ──[Transform/color]──> clip1_color.mp4 ──[Transform/overlay]──> clip1_final.mp4
    ├─[Time/trim]──> clip2.mp4 ──[Transform/color]──> clip2_color.mp4 ──[Transform/overlay]──> clip2_final.mp4
    └─[Time/trim]──> clip3.mp4 ──[Transform/color]──> clip3_color.mp4 ──[Transform/overlay]──> clip3_final.mp4
                                                                                │
                                                                                ├─[Time/concat]──> video_sequence.mp4
                                                                                                        │
                                                                                                        ├─[Space/extract-audio]──> video_audio.wav
                                                                                                        │                               │
                                                                                                        │                               └─[Transform/normalize]──> video_audio_norm.wav
                                                                                                        │                                                               │
intro_music.mp3 ──[Transform/fade]──> intro_fade.mp3 ──┐                                              │                                                               │
                                                         ├─[Time/concat-audio]──> temp1.wav ──┐        │                                                               │
outro_music.mp3 ──[Transform/fade]──> outro_fade.mp3 ──┘                                      │        │                                                               │
                                                                                                └─[Time/concat-audio]──> final_audio.wav ──┐                           │
                                                                                                                                            │                           │
                                                                                                                                            └─[Space/merge-av]──> final_with_audio.mp4
                                                                                                                                                                        │
                                                                                                                                                                        └─[Context/h265]──> final_output.mp4
```

### Category Usage Summary
- **Preamble**: Inspect input/output (probe, video-info, duration)
- **Context**: Final transcode to H265
- **Space**: Extract audio, merge audio/video
- **Time**: Trim clips, concatenate video/audio
- **Transform**: Color correction, watermark overlay, audio normalization, fade effects

---

## Implementation Status

- [x] Directory structure (Monads/LocalIO/{Preamble,Context,Space,Time,Transform})
- [x] Preamble justfile (probe/inspect)
- [x] Context justfile (remux/transcode)
- [x] Space justfile (extract/merge)
- [x] Time justfile (trim/concat/sync)
- [x] Transform justfile (filters/effects)
- [x] End-to-end workflow example

---

Last Updated: 2026-01-22
