#!/usr/bin/env nu

# Interpreter for Export - reads config, renders to format
def main [config_path: string] {
  let cfg = (open $config_path | get audio.export)
  
  let codec = match $cfg.format {
    "mp3" => "libmp3lame"
    "ogg" => "libvorbis"
    "opus" => "libopus"
    "flac" => "flac"
    "wav" => "pcm_s16le"
  }
  
  print $"Rendering ($cfg.input) to ($cfg.format) at ($cfg.bitrate)..."
  ffmpeg -y -i $cfg.input -c:a $codec -b:a $cfg.bitrate -ar $cfg.sampleRate $cfg.output
  print $"Created: ($cfg.output)"
}
