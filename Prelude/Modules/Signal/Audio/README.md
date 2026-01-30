# Audio Module

Declarative audio engineering pipeline.

## Capability Space

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ Acquire │───▶│ Analyze │───▶│Transform│───▶│ Segment │───▶│ Export  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
  yt-dlp         ffprobe        ffmpeg         ffmpeg         ffmpeg
  wget           sox            sox
```

## Sum Types (Universe/)

| Feature | Purpose | Tools |
|---------|---------|-------|
| Acquire | Fetch media from URLs | yt-dlp, wget |
| Analyze | BPM, key, spectrum analysis | ffprobe, sox |
| Transform | Filters, effects, tempo | ffmpeg -af |
| Segment | Split, trim, concat, fade | ffmpeg |
| Export | Format conversion | ffmpeg, lame |

## Options

### Acquire
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| url | str | "" | Source URL |
| format | enum | "best" | Download format |
| outputDir | str | "./downloads" | Output directory |

### Analyze
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| bpm | bool | false | Detect BPM |
| key | bool | false | Detect musical key |
| spectrum | bool | false | Generate spectrum |
| loudness | bool | false | Measure loudness |

### Transform
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| highpass | int? | null | Highpass filter Hz |
| lowpass | int? | null | Lowpass filter Hz |
| volume | str | "1.0" | Volume multiplier |
| tempo | str | "1.0" | Tempo multiplier |
| pitch | int? | null | Pitch shift semitones |
| normalize | bool | false | Normalize audio |

### Segment
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| trimStart | str? | null | Start time (HH:MM:SS) |
| trimEnd | str? | null | End time |
| splitAt | [str] | [] | Split points |
| fadeIn | str? | null | Fade in duration |
| fadeOut | str? | null | Fade out duration |

### Export
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| format | enum | "mp3" | Output format |
| bitrate | str | "320k" | Audio bitrate |
| sampleRate | int | 44100 | Sample rate Hz |
| channels | 1\|2 | 2 | Mono/Stereo |

## Usage

```nix
{
  audio = {
    enable = true;
    acquire.format = "mp3";
    transform.tempo = "1.25";
    transform.highpass = 200;
    export.format = "opus";
    export.bitrate = "128k";
  };
}
```

```bash
nix develop .#audio
yt-dlp -x --audio-format $AUDIO_ACQUIRE_FORMAT "$URL"
ffmpeg -i input.mp3 -af "highpass=200,atempo=1.25" -c:a libopus -b:a 128k output.opus
```

## Targets

| Target | Purpose |
|--------|---------|
| `perSystem.devShells.audio` | Development environment |
