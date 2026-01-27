# LocalIO/Context: Format conversion (remux/transcode)
# Container and codec transformations + fetch operations

# === Fetch Operations ===

# Fetch from URL (generic download)
fetch URL OUTPUT:
    curl -L "{{URL}}" -o "{{OUTPUT}}"

# Fetch to StorageIO/audio
fetch-audio URL FILENAME:
    curl -L "{{URL}}" -o "../../../Types/Inputs/StorageIO/audio/{{FILENAME}}"

# Fetch to StorageIO/video
fetch-video URL FILENAME:
    curl -L "{{URL}}" -o "../../../Types/Inputs/StorageIO/video/{{FILENAME}}"

# Fetch to StorageIO/images
fetch-image URL FILENAME:
    curl -L "{{URL}}" -o "../../../Types/Inputs/StorageIO/images/{{FILENAME}}"

# Fetch from Internet Archive
fetch-archive IDENTIFIER FILENAME:
    curl -L "https://archive.org/download/{{IDENTIFIER}}/{{FILENAME}}" -o "../../../Types/Inputs/StorageIO/video/{{FILENAME}}"

# === Format Conversion ===

# Remux: Change container without re-encoding
remux INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -c copy "{{OUTPUT}}"

# Audio: Encode to MP3
audio-encode-mp3 INPUT OUTPUT BITRATE="192k":
    ffmpeg -i "{{INPUT}}" -c:a libmp3lame -b:a {{BITRATE}} "{{OUTPUT}}"

# Audio: Encode to AAC
audio-encode-aac INPUT OUTPUT BITRATE="192k":
    ffmpeg -i "{{INPUT}}" -c:a aac -b:a {{BITRATE}} "{{OUTPUT}}"

# Audio: Encode to Opus
audio-encode-opus INPUT OUTPUT BITRATE="128k":
    ffmpeg -i "{{INPUT}}" -c:a libopus -b:a {{BITRATE}} "{{OUTPUT}}"

# Audio: Encode to FLAC (lossless)
audio-encode-flac INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -c:a flac "{{OUTPUT}}"

# Video: Encode to H264
video-encode-h264 INPUT OUTPUT CRF="23":
    ffmpeg -i "{{INPUT}}" -c:v libx264 -crf {{CRF}} -c:a copy "{{OUTPUT}}"

# Video: Encode to H265
video-encode-h265 INPUT OUTPUT CRF="28":
    ffmpeg -i "{{INPUT}}" -c:v libx265 -crf {{CRF}} -c:a copy "{{OUTPUT}}"

# Video: Encode to VP9
video-encode-vp9 INPUT OUTPUT CRF="30":
    ffmpeg -i "{{INPUT}}" -c:v libvpx-vp9 -crf {{CRF}} -b:v 0 -c:a libopus "{{OUTPUT}}"

# Full transcode: video + audio
transcode INPUT OUTPUT VCODEC="libx264" ACODEC="aac":
    ffmpeg -i "{{INPUT}}" -c:v {{VCODEC}} -c:a {{ACODEC}} "{{OUTPUT}}"
