#!/usr/bin/env nu
# Watch - File change detection
# Interprets lab.watch Options
# Binding: entr

def main [config_json: string] {
  let cfg = ($config_json | from json)
  let patterns = ($cfg.patterns? | default [])
  let command = ($cfg.command? | default "echo changed")
  
  if ($patterns | is-empty) {
    print "No patterns specified"
    return
  }
  
  # Build file list from patterns
  let files = ($patterns | each { |p| glob $p } | flatten)
  
  if ($files | is-empty) {
    print $"No files match patterns: ($patterns)"
    return
  }
  
  print $"Watching ($files | length) files..."
  print $"Command: ($command)"
  
  # Pipe file list to entr
  $files | str join "\n" | entr -p $command
}
