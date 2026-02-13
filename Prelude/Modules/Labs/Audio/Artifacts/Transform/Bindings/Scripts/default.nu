#!/usr/bin/env nu

# Interpreter for Transform - reads config, builds ffmpeg filter chain
# Config: { input, output, transforms: [{type, params}] }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  
  if ($cfg.transforms | is-empty) {
    print "No transforms specified"
    return
  }
  
  # Build filter chain from transforms list
  let filters: string = ($cfg.transforms | each {|t|
    match $t.type {
      "pitch" => {
        let semitones: int = ($t.params.semitones? | default 0)
        let factor: float = (2 ** ($semitones / 12))
        $"asetrate=44100*($factor),aresample=44100"
      }
      "stretch" => {
        let factor: float = ($t.params.factor? | default 1.0)
        $"atempo=($factor)"
      }
      "filter" => {
        let kind: string = ($t.params.kind? | default "highpass")
        let freq: int = ($t.params.freq? | default 200)
        $"($kind)=f=($freq)"
      }
      "volume" => {
        let level: float = ($t.params.level? | default 1.0)
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
  
  ffmpeg -y -loglevel error -i $cfg.input -af $filters $cfg.output
}
