#!/usr/bin/env nu

# Interpreter for Analyze - reads config, runs analysis
def main [config_path: string] {
  let cfg = (open $config_path | get audio.analyze)
  mkdir $cfg.outputDir
  
  if $cfg.spectrum {
    print $"Generating spectrum for ($cfg.input)..."
    let out = $"($cfg.outputDir)/spectrum.png"
    ffmpeg -y -i $cfg.input -lavfi showspectrumpic=s=1024x512 $out
    print $"Created: ($out)"
  }
  
  if $cfg.waveform {
    print $"Generating waveform for ($cfg.input)..."
    let out = $"($cfg.outputDir)/waveform.png"
    ffmpeg -y -i $cfg.input -lavfi showwavespic=s=1024x256 $out
    print $"Created: ($out)"
  }
  
  if $cfg.loudness {
    print $"Analyzing loudness for ($cfg.input)..."
    let result = (ffmpeg -i $cfg.input -af loudnorm=print_format=summary -f null - 2>&1)
    print $result
  }
}
