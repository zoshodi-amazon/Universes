#!/usr/bin/env nu

# Interpreter for Export - reads config, renders to format
# Config: { input, output, format, bitrate?, sampleRate? }
def main [config_json: string] {
  let cfg = ($config_json | from json)
  let bitrate = ($cfg.bitrate? | default "320k")
  let sample_rate = ($cfg.sampleRate? | default 44100)
  
  let codec = match $cfg.format {
    "mp3" => "libmp3lame"
    "ogg" => "libvorbis"
    "opus" => "libopus"
    "flac" => "flac"
    "wav" => "pcm_s16le"
  }
  
  print $"Rendering ($cfg.input) to ($cfg.format) at ($bitrate)..."
  ffmpeg -y -i $cfg.input -c:a $codec -b:a $bitrate -ar $sample_rate $cfg.output
  print $"Created: ($cfg.output)"
}
