#!/usr/bin/env nu

# Interpreter for Acquire - reads config, fetches/generates audio
# Config: { source, url?, input?, generate?, output }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  
  match $cfg.source {
    "url" => {
      mkdir ($cfg.output | path dirname)
      if ($cfg.url | str contains "youtube") or ($cfg.url | str contains "youtu.be") {
        yt-dlp -q -x --audio-format wav -o $cfg.output $cfg.url
      } else {
        curl -sL -o $cfg.output $cfg.url
      }
    }
    "file" => {
      cp $cfg.input $cfg.output
    }
    "generate" => {
      let g: record = $cfg.generate
      let filter: string = match $g.waveform {
        "sine" => $"sine=frequency=($g.frequency):duration=($g.duration)"
        "square" => $"sine=frequency=($g.frequency):duration=($g.duration)"
        "noise" => $"anoisesrc=duration=($g.duration)"
      }
      ffmpeg -y -loglevel error -f lavfi -i $filter $cfg.output
    }
  }
  print $"Output: ($cfg.output)"
}
