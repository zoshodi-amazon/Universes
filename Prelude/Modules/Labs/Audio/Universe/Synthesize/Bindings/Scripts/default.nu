#!/usr/bin/env nu

# Interpreter for Synthesize - reads config, generates audio
def main [config_path: string] {
  let cfg = (open $config_path | get audio.synthesize)
  let env = $cfg.envelope
  
  print $"Generating ($cfg.waveform) at ($cfg.frequency)Hz for ($cfg.duration)s..."
  
  let source = match $cfg.waveform {
    "sine" => $"sine=frequency=($cfg.frequency):duration=($cfg.duration)"
    "square" => $"sine=frequency=($cfg.frequency):duration=($cfg.duration)"
    "noise" => $"anoisesrc=duration=($cfg.duration)"
    _ => $"sine=frequency=($cfg.frequency):duration=($cfg.duration)"
  }
  
  # Apply envelope (fade in/out approximation)
  let filter = $"($source),afade=t=in:st=0:d=($env.attack),afade=t=out:st=(($cfg.duration | into float) - ($env.release | into float)):d=($env.release)"
  
  ffmpeg -y -f lavfi -i $filter $cfg.output
  print $"Created: ($cfg.output)"
}
