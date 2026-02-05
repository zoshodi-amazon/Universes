#!/usr/bin/env nu

# Interpreter for Synthesize - reads config, generates audio
# Config: { waveform, frequency, duration, envelope?, output }
def main [config_json: string] {
  let cfg = ($config_json | from json)
  let adsr = ($cfg.envelope? | default {attack: "0.01", release: "0.1"})
  
  print $"Generating ($cfg.waveform) at ($cfg.frequency)Hz for ($cfg.duration)s..."
  
  let source = match $cfg.waveform {
    "sine" => $"sine=frequency=($cfg.frequency):duration=($cfg.duration)"
    "square" => $"sine=frequency=($cfg.frequency):duration=($cfg.duration)"
    "noise" => $"anoisesrc=duration=($cfg.duration)"
    _ => $"sine=frequency=($cfg.frequency):duration=($cfg.duration)"
  }
  
  let attack = ($adsr.attack? | default "0.01")
  let release = ($adsr.release? | default "0.1")
  let dur_float = ($cfg.duration | into float)
  let release_float = ($release | into float)
  let fade_start = ($dur_float - $release_float)
  
  let filter = $"($source),afade=t=in:st=0:d=($attack),afade=t=out:st=($fade_start):d=($release)"
  
  ffmpeg -y -f lavfi -i $filter $cfg.output
  print $"Created: ($cfg.output)"
}
