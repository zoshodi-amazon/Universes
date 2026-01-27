# LocalIO/Transform: Filters and effects (audio/video)
# Endomorphisms within codec space

# === Audio Filters ===

# Normalize audio volume
audio-normalize INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -af loudnorm "{{OUTPUT}}"

# Adjust volume (0.5 = half, 2.0 = double)
audio-volume INPUT OUTPUT LEVEL:
    ffmpeg -i "{{INPUT}}" -af "volume={{LEVEL}}" "{{OUTPUT}}"

# Apply equalizer (bass, mid, treble in dB)
audio-eq INPUT OUTPUT BASS MID TREBLE:
    ffmpeg -i "{{INPUT}}" -af "equalizer=f=100:t=h:width=200:g={{BASS}},equalizer=f=1000:t=h:width=200:g={{MID}},equalizer=f=10000:t=h:width=200:g={{TREBLE}}" "{{OUTPUT}}"

# Fade in/out (duration in seconds)
audio-fade INPUT OUTPUT FADEIN FADEOUT:
    ffmpeg -i "{{INPUT}}" -af "afade=t=in:st=0:d={{FADEIN}},afade=t=out:st=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 {{INPUT}} | awk '{print $1-{{FADEOUT}}'):d={{FADEOUT}}" "{{OUTPUT}}"

# Remove silence from audio
audio-remove-silence INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -af "silenceremove=start_periods=1:start_duration=1:start_threshold=-60dB:detection=peak,aformat=dblp,areverse,silenceremove=start_periods=1:start_duration=1:start_threshold=-60dB:detection=peak,aformat=dblp,areverse" "{{OUTPUT}}"

# Mix two audio tracks (weights: 0.0-1.0)
audio-mix INPUT1 INPUT2 OUTPUT WEIGHT1="0.5" WEIGHT2="0.5":
    ffmpeg -i "{{INPUT1}}" -i "{{INPUT2}}" -filter_complex "[0:a]volume={{WEIGHT1}}[a1];[1:a]volume={{WEIGHT2}}[a2];[a1][a2]amix=inputs=2:duration=longest" "{{OUTPUT}}"

# === Video Filters ===

# Scale video to resolution
video-scale INPUT OUTPUT WIDTH HEIGHT:
    ffmpeg -i "{{INPUT}}" -vf "scale={{WIDTH}}:{{HEIGHT}}" "{{OUTPUT}}"

# Scale maintaining aspect ratio (width=-1 auto-calculates)
video-scale-aspect INPUT OUTPUT HEIGHT:
    ffmpeg -i "{{INPUT}}" -vf "scale=-1:{{HEIGHT}}" "{{OUTPUT}}"

# Crop video (width:height:x:y)
video-crop INPUT OUTPUT WIDTH HEIGHT X Y:
    ffmpeg -i "{{INPUT}}" -vf "crop={{WIDTH}}:{{HEIGHT}}:{{X}}:{{Y}}" "{{OUTPUT}}"

# Rotate video (angle in degrees)
video-rotate INPUT OUTPUT ANGLE:
    ffmpeg -i "{{INPUT}}" -vf "rotate={{ANGLE}}*PI/180" "{{OUTPUT}}"

# Overlay video on top of another (x, y position)
video-overlay BASE OVERLAY OUTPUT X Y:
    ffmpeg -i "{{BASE}}" -i "{{OVERLAY}}" -filter_complex "[0:v][1:v]overlay={{X}}:{{Y}}" "{{OUTPUT}}"

# Adjust brightness/contrast (brightness: -1 to 1, contrast: -1 to 1)
video-brightness-contrast INPUT OUTPUT BRIGHTNESS CONTRAST:
    ffmpeg -i "{{INPUT}}" -vf "eq=brightness={{BRIGHTNESS}}:contrast={{CONTRAST}}" "{{OUTPUT}}"

# Convert to grayscale
video-grayscale INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -vf "hue=s=0" "{{OUTPUT}}"

# Apply blur effect
video-blur INPUT OUTPUT RADIUS="5":
    ffmpeg -i "{{INPUT}}" -vf "boxblur={{RADIUS}}" "{{OUTPUT}}"

# Stabilize shaky video
video-stabilize INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -vf "vidstabdetect=shakiness=10:accuracy=15" -f null - && \
    ffmpeg -i "{{INPUT}}" -vf "vidstabtransform=smoothing=30:input=transforms.trf" "{{OUTPUT}}"

# === Filter Chains ===

# Complex filter chain example: scale + crop + brightness
video-chain INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -vf "scale=1920:1080,crop=1920:800:0:140,eq=brightness=0.1:contrast=1.2" "{{OUTPUT}}"

# Audio + Video filter chain
av-chain INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -vf "scale=1280:720" -af "loudnorm,volume=1.5" "{{OUTPUT}}"

# === Live Rendering ===

# Generate waveform PNG
waveform INPUT OUTPUT="waveform.png":
    ffmpeg -i "{{INPUT}}" -filter_complex "showwavespic=s=1920x480:colors=white" -frames:v 1 "{{OUTPUT}}"

# Generate spectrogram PNG
spectrogram INPUT OUTPUT="spectrogram.png":
    sox "{{INPUT}}" -n spectrogram -o "{{OUTPUT}}"

# Live waveform preview (watches file, regenerates on change)
watch-waveform INPUT OUTPUT="waveform.png":
    watchexec -w "{{INPUT}}" -- ffmpeg -y -i "{{INPUT}}" -filter_complex "showwavespic=s=1920x480:colors=white" -frames:v 1 "{{OUTPUT}}"

# Live spectrogram preview
watch-spectrogram INPUT OUTPUT="spectrogram.png":
    watchexec -w "{{INPUT}}" -- sox "{{INPUT}}" -n spectrogram -o "{{OUTPUT}}"

# Watch and render both
watch-all INPUT:
    watchexec -w "{{INPUT}}" -- sh -c 'ffmpeg -y -i "{{INPUT}}" -filter_complex "showwavespic=s=1920x480" -frames:v 1 waveform.png && sox "{{INPUT}}" -n spectrogram -o spectrogram.png'
