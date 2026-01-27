# LocalIO/Time: Temporal operations (trim/concat/sync)
# Timeline manipulation

# Trim/cut segment (start and duration in seconds)
trim INPUT OUTPUT START DURATION:
    ffmpeg -i "{{INPUT}}" -ss {{START}} -t {{DURATION}} -c copy "{{OUTPUT}}"

# Trim with re-encode (for precise cuts)
trim-reencode INPUT OUTPUT START DURATION:
    ffmpeg -i "{{INPUT}}" -ss {{START}} -t {{DURATION}} "{{OUTPUT}}"

# Concatenate files (requires concat list file)
concat LISTFILE OUTPUT:
    ffmpeg -f concat -safe 0 -i "{{LISTFILE}}" -c copy "{{OUTPUT}}"

# Concatenate two files directly
concat-two FILE1 FILE2 OUTPUT:
    ffmpeg -i "{{FILE1}}" -i "{{FILE2}}" -filter_complex "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[outv][outa]" -map "[outv]" -map "[outa]" "{{OUTPUT}}"

# Concatenate audio files
concat-audio FILE1 FILE2 OUTPUT:
    ffmpeg -i "{{FILE1}}" -i "{{FILE2}}" -filter_complex "[0:a][1:a]concat=n=2:v=0:a=1[outa]" -map "[outa]" "{{OUTPUT}}"

# Sync audio/video with offset (offset in seconds, positive = delay audio)
sync VIDEO AUDIO OUTPUT OFFSET:
    ffmpeg -i "{{VIDEO}}" -itsoffset {{OFFSET}} -i "{{AUDIO}}" -map 0:v -map 1:a -c copy "{{OUTPUT}}"

# Speed up/slow down (rate: 2.0 = 2x speed, 0.5 = half speed)
speed INPUT OUTPUT RATE:
    ffmpeg -i "{{INPUT}}" -filter_complex "[0:v]setpts={{RATE}}*PTS[v];[0:a]atempo={{RATE}}[a]" -map "[v]" -map "[a]" "{{OUTPUT}}"

# Loop video/audio N times
loop INPUT OUTPUT COUNT:
    ffmpeg -stream_loop {{COUNT}} -i "{{INPUT}}" -c copy "{{OUTPUT}}"

# Extract segment between two timestamps (HH:MM:SS format)
extract-range INPUT OUTPUT START END:
    ffmpeg -i "{{INPUT}}" -ss {{START}} -to {{END}} -c copy "{{OUTPUT}}"

# Create concat list file from multiple inputs
create-concat-list OUTPUT FILES:
    #!/usr/bin/env bash
    for f in {{FILES}}; do echo "file '$f'" >> "{{OUTPUT}}"; done
