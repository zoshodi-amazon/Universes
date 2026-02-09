#!/usr/bin/env nu

# Interpreter for Core - init and status
# Config: { action: "init" | "status", projectDir: string }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)

  match $cfg.action {
    "init" => {
      let dirs: list<string> = [
        $cfg.projectDir
        ([$cfg.projectDir "sprites"] | path join)
        ([$cfg.projectDir "renders"] | path join)
        ([$cfg.projectDir "audio"] | path join)
        ([$cfg.projectDir "assets"] | path join)
        ([$cfg.projectDir "models"] | path join)
        ([$cfg.projectDir "exports"] | path join)
      ]
      $dirs | each {|d| mkdir $d }
      ["Initialized" $cfg.projectDir] | str join " " | print
    }
    "status" => {
      let dirs: list<string> = ["sprites" "renders" "audio" "assets" "models" "exports"]
      $dirs | each {|d|
        let p: string = [$cfg.projectDir $d] | path join
        let count: int = if ($p | path exists) { ls $p | length } else { 0 }
        ["  " $d ":" ($count | into string) "files"] | str join " " | print
      }
      null
    }
  }
}
