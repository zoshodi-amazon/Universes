#!/usr/bin/env nu

# Interpreter for Preview - play or visualize audio
# Config: { input, mode: "play" | "waveform" | "spectrum" }
def main [config_json: string] {
  let cfg = ($config_json | from json)
  
  match $cfg.mode {
    "play" => {
      print $"Playing ($cfg.input)..."
      ffplay -nodisp -autoexit $cfg.input
    }
    "waveform" => {
      print $"Waveform: ($cfg.input)"
      ffplay -f lavfi $"amovie=($cfg.input),showwaves=s=1280x320:mode=line"
    }
    "spectrum" => {
      print $"Spectrum: ($cfg.input)"
      ffplay -f lavfi $"amovie=($cfg.input),showspectrum=s=1280x640"
    }
  }
}
