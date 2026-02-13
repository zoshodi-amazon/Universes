# Audio

Signal processing workstation. Metric space observation and transforms via ffmpeg.

## Metric Space

The audio domain is a compact metric space. Every audio artifact is fully described by these orthogonal dimensions:

| Metric | Unit | Bounds | What it measures |
|--------|------|--------|-----------------|
| Frequency | Hz, kHz | 20 Hz — 20 kHz | Pitch / spectral content |
| Amplitude | dB, dBFS | -inf — 0 dBFS | Loudness / energy |
| Duration | ms, s, min | 0 — unbounded | Time extent |
| SampleRate | Hz, kHz | 8000 — 192000 | Temporal resolution |
| BitDepth | bits | 16, 24, 32 | Amplitude resolution |
| Channels | count | 1 — 8 | Spatial dimensions |

Transforms are morphisms over this metric space — they rotate, translate, project, or compose metric states.

## Visualization Invariant

**All audio artifacts MUST be visually observable.** Rendering is a fold over the metric space. ffplay with `amovie+asplit` is the canonical renderer — one copy to speakers, one to visualizer. Signal MUST fill the frame.

```bash
# Canonical render pattern: amovie loads, asplit routes audio + video separately
ffplay -f lavfi \
  "amovie=<file>,volume=4,asplit[a][out1];[a]showspectrum=s=800x800:color=rainbow:slide=scroll:scale=cbrt:saturation=4[out0]" \
  -x 800 -y 800 -loop 0
```

**Color = frequency.** Low frequencies red, high frequencies violet. Amplitude = brightness. Time = horizontal scroll. This maps the full metric space to visual perception:

| Metric | Visual encoding |
|--------|----------------|
| Frequency | Color (rainbow: red=low, violet=high) |
| Amplitude | Brightness |
| Time | Horizontal scroll position |
| Harmony | Vertical band clustering (chords = parallel colored lines) |
| Tension | Color spread (dissonance = wider spectrum, consonance = tight bands) |
| Mood | Color temperature (minor = cooler hues dominate, major = warmer) |

Available color maps: `rainbow`, `fire`, `cool`, `magma`, `plasma`, `viridis`, `nebulae`, `intensity`, `channel`.

Available A->V projections:

| Filter | What it shows | Best for |
|--------|--------------|----------|
| showspectrum | Frequency vs time, color = frequency | Chord progressions, melody, mood |
| showcqt | Constant Q (musical pitch axis) | Note identification, harmony |
| avectorscope | Lissajous / phase portrait | Harmonic field structure |
| a3dscope | 3D oscilloscope | Metric space geometry |
| showcwt | Continuous Wavelet Transform | Time-frequency decomposition |
| showfreqs | Instantaneous frequency bars | Real-time spectrum |
| showwaves | Time domain waveform | Amplitude envelope |

## Musical Analysis via Color

Chord progressions are visible as colored band patterns:

| Musical concept | Visual signature |
|----------------|-----------------|
| Root note | Dominant color band (lowest bright line) |
| Chord quality | Band spacing (major = wide, minor = narrow third) |
| Chord change | Color shift (new bands appear, old fade) |
| Melody | Moving bright line above chord bands |
| Tension/release | Spectrum width (tension = spread, release = collapse) |
| Reverb/space | Horizontal smear (longer tails = more space) |
| Dynamics | Overall brightness change |

## Transforms

| Transform | Metric effect | ffmpeg filter |
|-----------|--------------|---------------|
| Pitch shift | Frequency translation | `asetrate`, `rubberband` |
| Low-pass | Frequency truncation (projection onto subspace) | `lowpass=f=N` |
| High-pass | Frequency truncation (complement projection) | `highpass=f=N` |
| Reverb | Temporal expansion | `aecho` |
| Normalize | Amplitude scaling to bounds | `loudnorm` |
| Mix | Metric space product (superposition) | `amix` |
| Resample | SampleRate translation | `aresample` |
| Compress | Amplitude nonlinear map | `acompressor` |

## Justfile Recipes

```
just ffmpeg-audio <file>            # CQT pitch field (color per note)
just ffmpeg-audio-spectrum <file>   # Rainbow spectrogram (color per frequency)
just ffmpeg-audio-lissajous <file>  # Phase portrait (harmonic structure)
just ffmpeg-audio-3d <file>         # 3D oscilloscope
just io-ffmpeg-audio-melancholy     # Generate melancholic Am-F-C-G progression
```
