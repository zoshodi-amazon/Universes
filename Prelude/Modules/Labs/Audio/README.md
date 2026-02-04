# Audio

Signal processing workstation. Pure data transforms interpreted via ffmpeg.

## Features

| Feature | Capability |
|---------|------------|
| Acquire | Fetch, record, generate audio sources |
| Analyze | Spectrum, loudness, tempo, waveform analysis |
| Transform | Pitch, stretch, filter, dynamics, effects |
| Synthesize | Tone generation, noise, envelopes |
| Compose | Sequence, layer, mix audio |
| Export | Render to various formats |

## Options

See `just options Modules/Labs/Audio`

## Usage

All configuration via Options (pure data). Scripts interpret Options into ffmpeg calls.

```nix
audio.transform.transforms = [
  { type = "filter"; params = { kind = "highpass"; freq = 200; }; }
  { type = "pitch"; params = { semitones = 3; }; }
];
```

```bash
cd Modules/Labs/Audio
just transform input.wav output.wav
```
