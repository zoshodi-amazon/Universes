#!/usr/bin/env nu

# Interpreter for Compose - reads config, sequences or layers audio
# Config: { inputs: [], mode: "sequence" | "layer", output }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  
  if ($cfg.inputs | length) < 2 {
    print "Need at least 2 inputs to compose"
    return
  }
  
  match $cfg.mode {
    "sequence" => {
      let concat_file: string = "/tmp/concat_list.txt"
      let abs_inputs: list<string> = ($cfg.inputs | each {|i| $i | path expand})
      $abs_inputs | each {|i| $"file '($i)'"} | str join "\n" | save -f $concat_file
      ffmpeg -y -loglevel error -f concat -safe 0 -i $concat_file -c copy $cfg.output
    }
    "layer" => {
      let abs_inputs: list<string> = ($cfg.inputs | each {|i| $i | path expand})
      let input_args: string = ($abs_inputs | each {|i| $"-i ($i)"} | str join " ")
      let filter: string = $"amix=inputs=($cfg.inputs | length):duration=longest"
      nu -c $"ffmpeg -y -loglevel error ($input_args) -filter_complex '($filter)' ($cfg.output)"
    }
  }
}
