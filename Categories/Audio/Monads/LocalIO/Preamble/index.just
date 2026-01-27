# LocalIO/Preamble: f^* (Pull) - Inspection without transformation
# ffprobe-based metadata queries + catalog operations

# === Catalog Operations ===

# List available input media
catalog-input:
    ls -lh "$AUDIO_INPUT_DIR"

# List output media
catalog-output:
    ls -lh "$AUDIO_OUTPUT_DIR"

# Show public domain sources
sources:
    @echo "Public Domain Media Sources:"
    @echo "- Internet Archive: https://archive.org"
    @echo "- Wikimedia Commons: https://commons.wikimedia.org"
    @echo "- Free Music Archive: https://freemusicarchive.org"

# Play media file
play FILE:
    ffplay -autoexit "{{FILE}}"

# === Inspection Operations ===

# Probe full metadata
probe FILE:
    ffprobe -v quiet -print_format json -show_format -show_streams "{{FILE}}"

# Get format info (container, duration, bitrate)
format FILE:
    ffprobe -v quiet -print_format json -show_format "{{FILE}}" | jq '.format | {format_name, duration, bit_rate, size}'

# List all streams (audio/video/subtitle)
streams FILE:
    ffprobe -v quiet -print_format json -show_streams "{{FILE}}" | jq '.streams[] | {index, codec_type, codec_name}'

# Get audio stream info
audio-info FILE:
    ffprobe -v quiet -select_streams a:0 -print_format json -show_streams "{{FILE}}" | jq '.streams[0] | {codec_name, sample_rate, channels, bit_rate}'

# Get video stream info
video-info FILE:
    ffprobe -v quiet -select_streams v:0 -print_format json -show_streams "{{FILE}}" | jq '.streams[0] | {codec_name, width, height, r_frame_rate, bit_rate}'

# Get duration in seconds
duration FILE:
    ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "{{FILE}}"

# Verify file integrity
verify FILE:
    ffmpeg -v error -i "{{FILE}}" -f null - 2>&1
