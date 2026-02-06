#!/usr/bin/env nu
# Preset - Launch tmux session with capability-complete layout
#
# Presets defined inline - no external config files needed

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let preset: string = ($cfg.preset? | default "explore")
  let workdir: string = ($cfg.workdir? | default "." | path expand)
  let session: string = $"($preset)-($workdir | path basename)"
  
  # Kill existing session if exists
  do { ^tmux kill-session -t $session } | complete | ignore
  
  # Create session and apply preset
  ^tmux new-session -d -s $session -c $workdir
  
  match $preset {
    "explore" => { preset_explore $session $workdir }
    "compare" => { preset_compare $session $workdir }
    "monitor" => { preset_monitor $session $workdir }
    "develop" => { preset_develop $session $workdir }
    _ => { print $"Unknown preset: ($preset)" ; return }
  }
  
  # Select first pane and attach
  ^tmux select-pane -t $"($session):.0"
  ^tmux attach-session -t $session
}

# Explore: preview + control | library + logs (4 panes)
def preset_explore [session: string, workdir: string]: nothing -> nothing {
  ^tmux split-window -h -t $session -c $workdir -p 40
  ^tmux split-window -v -t $"($session):.1" -c $workdir -p 50
  ^tmux split-window -v -t $"($session):.0" -c $workdir -p 40
}

# Compare: preview-a | preview-b / metrics + control (4 panes)
def preset_compare [session: string, workdir: string]: nothing -> nothing {
  ^tmux split-window -h -t $session -c $workdir -p 50
  ^tmux split-window -v -t $"($session):.0" -c $workdir -p 30
  ^tmux split-window -h -t $"($session):.2" -c $workdir -p 50
}

# Monitor: metrics | logs / alerts (3 panes)
def preset_monitor [session: string, workdir: string]: nothing -> nothing {
  ^tmux split-window -h -t $session -c $workdir -p 40
  ^tmux split-window -v -t $"($session):.1" -c $workdir -p 40
}

# Develop: editor | test / logs (3 panes)
def preset_develop [session: string, workdir: string]: nothing -> nothing {
  ^tmux split-window -h -t $session -c $workdir -p 40
  ^tmux split-window -v -t $"($session):.1" -c $workdir -p 50
}

# List available presets
def "main list" []: nothing -> nothing {
  [
    {name: "explore", description: "Lab work - preview, control, library, logs", panes: 4}
    {name: "compare", description: "A/B comparison - two previews, metrics, control", panes: 4}
    {name: "monitor", description: "Dashboard - metrics, logs, alerts", panes: 3}
    {name: "develop", description: "Coding - editor, test, logs", panes: 3}
  ] | print
}
