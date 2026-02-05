#!/usr/bin/env nu
# Layout - Tmux pane presets
# Strongly typed throughout

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let preset: string = ($cfg.preset? | default "explore")

  match $preset {
    "explore" => { layout_explore }
    "compare" => { layout_compare }
    "export" => { layout_export }
    "monitor" => { layout_monitor }
    _ => { print $"Unknown preset: ($preset)" }
  }
}

# Explore: preview/knobs + library/logs
def layout_explore []: nothing -> nothing {
  print "Setting up explore layout..."
  ^tmux split-window -h -p 40
  ^tmux split-window -v -p 50
  ^tmux select-pane -L
  ^tmux split-window -v -p 50
  print "Layout: explore"
}

# Compare: preview-a/preview-b + metrics
def layout_compare []: nothing -> nothing {
  print "Setting up compare layout..."
  ^tmux split-window -h -p 50
  ^tmux select-pane -L
  ^tmux split-window -v -p 30
  print "Layout: compare"
}

# Export: preview + settings/logs
def layout_export []: nothing -> nothing {
  print "Setting up export layout..."
  ^tmux split-window -v -p 40
  ^tmux split-window -h -p 50
  print "Layout: export"
}

# Monitor: metrics/logs + alerts
def layout_monitor []: nothing -> nothing {
  print "Setting up monitor layout..."
  ^tmux split-window -v -p 60
  ^tmux split-window -h -p 50
  print "Layout: monitor"
}
