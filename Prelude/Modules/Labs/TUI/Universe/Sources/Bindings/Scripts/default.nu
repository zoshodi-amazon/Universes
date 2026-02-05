#!/usr/bin/env nu
# Sources - Browse and fetch from remote repositories
#
# Actions: list, browse, fetch

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let action: string = ($cfg.action? | default "list")
  let sources_path: string = ($cfg.sources_path? | default ".lab/sources.json")
  
  match $action {
    "list" => { list_sources $sources_path }
    "browse" => { browse_source $cfg $sources_path }
    "fetch" => { fetch_asset $cfg $sources_path }
    _ => { print $"Unknown action: ($action)" }
  }
}

def list_sources [sources_path: string]: nothing -> nothing {
  if not ($sources_path | path exists) {
    print "No sources configured. Add sources to .lab/sources.json"
    return
  }
  
  let sources: list = (open $sources_path)
  
  if ($sources | is-empty) {
    print "No sources configured"
    return
  }
  
  $sources | select name type url tags | print
}

def browse_source [cfg: record, sources_path: string]: nothing -> nothing {
  let name: string = ($cfg.name? | default "")
  
  if ($name | is-empty) {
    # Interactive selection
    let sources: list = (open $sources_path)
    let names: list = ($sources | get name)
    let selected: string = ($names | str join "\n" | gum filter --placeholder "Select source...")
    browse_source {name: $selected} $sources_path
    return
  }
  
  let sources: list = (open $sources_path)
  let source: record = ($sources | where name == $name | first)
  
  print $"Browsing: ($source.name)"
  print $"URL: ($source.url)"
  print $"Extensions: ($source.extensions | str join ', ')"
  
  # For http sources, list available files
  if $source.type == "http" {
    print "\nFetching index..."
    # curl the URL and parse for links matching extensions
    let html: string = (curl -sL $source.url)
    let exts: string = ($source.extensions | str join "|")
    let pattern: string = $'href="([^"]+\.(?:($exts)))"'
    let matches: list = ($html | parse -r $pattern | get capture0)
    
    if ($matches | is-empty) {
      print "No matching files found"
    } else {
      $matches | print
    }
  }
}

def fetch_asset [cfg: record, sources_path: string]: nothing -> nothing {
  let source_name: string = ($cfg.source? | default "")
  let file: string = ($cfg.file? | default "")
  let output: string = ($cfg.output? | default ".lab/assets/")
  
  if ($source_name | is-empty) or ($file | is-empty) {
    print "Usage: fetch requires source and file"
    return
  }
  
  let sources: list = (open $sources_path)
  let source: record = ($sources | where name == $source_name | first)
  
  let url: string = $"($source.url)/($file)"
  let out_path: string = $"($output)/($file)"
  
  mkdir ($output | path dirname)
  
  print $"Fetching: ($url)"
  curl -sL $url -o $out_path
  print $"Saved: ($out_path)"
}
