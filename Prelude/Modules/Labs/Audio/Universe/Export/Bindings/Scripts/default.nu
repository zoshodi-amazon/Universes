#!/usr/bin/env nu

# Interpreter for Export - reads config, renders to format
# Config: { input, output, format, bitrate?, sampleRate? }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let bitrate: string = ($cfg.bitrate? | default "320k")
  let sample_rate: int = ($cfg.sampleRate? | default 44100)
  
  let codec: string = match $cfg.format {
    "mp3" => "libmp3lame"
    "ogg" => "libvorbis"
    "opus" => "libopus"
    "flac" => "flac"
    "wav" => "pcm_s16le"
  }
  
  mkdir ($cfg.output | path dirname)
  ffmpeg -y -loglevel error -i $cfg.input -c:a $codec -b:a $bitrate -ar $sample_rate $cfg.output
}
