#!/usr/bin/env nu

# Interpreter for Compose - reads config, sequences or layers audio
# Config: { inputs: [], mode: "sequence" | "layer", output }
def main [config_json: string] {
  let cfg = ($config_json | from json)
  
  if ($cfg.inputs | length) < 2 {
    print "Need at least 2 inputs to compose"
    return
  }
  
  match $cfg.mode {
    "sequence" => {
      print $"Sequencing ($cfg.inputs | length) files..."
      let concat_file = "/tmp/concat_list.txt"
      $cfg.inputs | each {|i| $"file '($i)'"} | str join "\n" | save -f $concat_file
      ffmpeg -y -f concat -safe 0 -i $concat_file -c copy $cfg.output
    }
    "layer" => {
      print $"Layering ($cfg.inputs | length) files..."
      let input_args = ($cfg.inputs | each {|i| [-i $i]} | flatten | str join " ")
      let filter = $"amix=inputs=($cfg.inputs | length):duration=longest"
      nu -c $"ffmpeg -y ($input_args) -filter_complex '($filter)' ($cfg.output)"
    }
  }
  
  print $"Created: ($cfg.output)"
}
