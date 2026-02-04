#!/usr/bin/env nu

# Interpreter for Transform - reads config, builds ffmpeg filter chain
def main [config_path: string] {
  let cfg = (open $config_path | get audio.transform)
  
  if ($cfg.transforms | is-empty) {
    print "No transforms specified"
    return
  }
  
  # Build filter chain from transforms list
  let filters = ($cfg.transforms | each {|t|
    match $t.type {
      "pitch" => {
        let semitones = ($t.params.semitones? | default 0)
        let factor = (2 ** ($semitones / 12))
        $"asetrate=44100*($factor),aresample=44100"
      }
      "stretch" => {
        let factor = ($t.params.factor? | default 1.0)
        $"atempo=($factor)"
      }
      "filter" => {
        let kind = ($t.params.kind? | default "highpass")
        let freq = ($t.params.freq? | default 200)
        $"($kind)=f=($freq)"
      }
      "volume" => {
        let level = ($t.params.level? | default 1.0)
        $"volume=($level)"
      }
      "reverb" => {
        "aecho=0.8:0.88:60:0.4"
      }
      "normalize" => {
        "loudnorm"
      }
    }
  } | str join ",")
  
  print $"Applying transforms: ($filters)"
  print $"Input: ($cfg.input) -> Output: ($cfg.output)"
  
  ffmpeg -y -i $cfg.input -af $filters $cfg.output
  print $"Created: ($cfg.output)"
}
