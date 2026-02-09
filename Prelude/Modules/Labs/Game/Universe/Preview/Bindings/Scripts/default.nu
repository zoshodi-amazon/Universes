#!/usr/bin/env nu

# Interpreter for Preview - terminal (chafa) or browser live preview
# Config: { action, method?, file?, watchDir?, extensions?, port? }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)

  match $cfg.action {
    "show" => {
      let file: string = $cfg.file
      match ($cfg.method? | default "terminal") {
        "terminal" => {
          ^chafa --size 80x40 $file
        }
        "browser" => {
          ["Open http://localhost:" (($cfg.port? | default 8090) | into string)] | str join "" | print
        }
      }
    }
    "watch" => {
      let dir: string = ($cfg.watchDir? | default ".lab")
      let exts: string = ($cfg.extensions? | default "png,gif,wav,mp3")
      let method: string = ($cfg.method? | default "terminal")
      match $method {
        "terminal" => {
          ["Watching" $dir "for" $exts "changes (chafa preview)"] | str join " " | print
          ^watchexec --exts $exts -w $dir -- chafa --size 80x40 --clear ([$dir "/renders/latest.png"] | path join)
        }
        "browser" => {
          let port: int = ($cfg.port? | default 8090)
          ["Serving" $dir "on port" ($port | into string)] | str join " " | print
          ^python3 -m http.server $port --directory $dir
        }
      }
    }
  }
}
