# LocalIO/Space: Stream manipulation (extract/merge)
# Spatial decomposition of audio/video streams

# Extract audio stream only
extract-audio INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -vn -c:a copy "{{OUTPUT}}"

# Extract video stream only (no audio)
extract-video INPUT OUTPUT:
    ffmpeg -i "{{INPUT}}" -an -c:v copy "{{OUTPUT}}"

# Extract specific stream by index
extract-stream INPUT OUTPUT STREAM:
    ffmpeg -i "{{INPUT}}" -map 0:{{STREAM}} -c copy "{{OUTPUT}}"

# Merge separate audio and video files
merge-av VIDEO AUDIO OUTPUT:
    ffmpeg -i "{{VIDEO}}" -i "{{AUDIO}}" -c:v copy -c:a copy "{{OUTPUT}}"

# Replace audio track in video
replace-audio VIDEO AUDIO OUTPUT:
    ffmpeg -i "{{VIDEO}}" -i "{{AUDIO}}" -map 0:v -map 1:a -c copy "{{OUTPUT}}"

# Add audio track (multi-track)
add-audio-track INPUT AUDIO OUTPUT:
    ffmpeg -i "{{INPUT}}" -i "{{AUDIO}}" -map 0 -map 1:a -c copy "{{OUTPUT}}"

# Extract all streams separately
extract-all INPUT PREFIX:
    ffmpeg -i "{{INPUT}}" -map 0:v -c copy "{{PREFIX}}_video.mp4" -map 0:a -c copy "{{PREFIX}}_audio.wav"

# Merge multiple audio streams (mix)
merge-audio AUDIO1 AUDIO2 OUTPUT:
    ffmpeg -i "{{AUDIO1}}" -i "{{AUDIO2}}" -filter_complex amix=inputs=2:duration=longest "{{OUTPUT}}"

# Select specific audio/video streams
select-streams INPUT OUTPUT VSTREAM="0:v:0" ASTREAM="0:a:0":
    ffmpeg -i "{{INPUT}}" -map {{VSTREAM}} -map {{ASTREAM}} -c copy "{{OUTPUT}}"
