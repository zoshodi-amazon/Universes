#!/usr/bin/env nu

# Interpreter for Asset - fetch, catalog, list
# Config: { action, url?, kind?, name?, storePath?, catalogDb? }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let store: string = ($cfg.storePath? | default ".lab/assets")

  match $cfg.action {
    "fetch" => {
      let url: string = $cfg.url
      let kind: string = ($cfg.kind? | default "sprite")
      let dir: string = [$store $kind] | path join
      mkdir $dir
      let filename: string = ($url | path basename)
      let out: string = [$dir $filename] | path join
      ^curl -sL -o $out $url
      ["Fetched:" $out] | str join " " | print
    }
    "list" => {
      if not ($store | path exists) {
        "No assets yet. Run: just asset-fetch <url> <kind>" | print
        return
      }
      ls $store | each {|d|
        if ($d.type == "dir") {
          let count: int = (ls $d.name | length)
          ["  " ($d.name | path basename) ":" ($count | into string) "files"] | str join " " | print
        }
      }
      null
    }
    "catalog" => {
      if not ($store | path exists) {
        "No assets to catalog" | print
        return
      }
      glob ([$store "**/*"] | path join) | where ($it | path type) == "file" | each {|f|
        let kind: string = ($f | path dirname | path basename)
        let name: string = ($f | path basename)
        let size: int = (ls $f | get 0.size)
        ["  " $kind "/" $name ($size | into string) "bytes"] | str join " " | print
      }
      null
    }
  }
}
