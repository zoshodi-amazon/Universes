#!/usr/bin/env nu

# Interpreter for Acquire - reads config, fetches/generates audio
# Config: { source, url?, input?, generate?, output }
def main [config_json: string] {
  let cfg = ($config_json | from json)
  
  match $cfg.source {
    "url" => {
      print $"Fetching from ($cfg.url)..."
      mkdir ($cfg.output | path dirname)
      if ($cfg.url | str contains "youtube") or ($cfg.url | str contains "youtu.be") {
        yt-dlp -x --audio-format wav -o $cfg.output $cfg.url
      } else {
        curl -L -o $cfg.output $cfg.url
      }
    }
    "file" => {
      print $"Copying ($cfg.input) to ($cfg.output)..."
      cp $cfg.input $cfg.output
    }
    "generate" => {
      let g = $cfg.generate
      print $"Generating ($g.waveform) at ($g.frequency)Hz for ($g.duration)s..."
      let filter = match $g.waveform {
        "sine" => $"sine=frequency=($g.frequency):duration=($g.duration)"
        "square" => $"sine=frequency=($g.frequency):duration=($g.duration)"
        "noise" => $"anoisesrc=duration=($g.duration)"
      }
      ffmpeg -y -f lavfi -i $filter $cfg.output
    }
  }
  print $"Output: ($cfg.output)"
}
