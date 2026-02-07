#!/usr/bin/env nu
# Preset - Launch tmux session with capability-complete layout
#
# Uses tmux select-layout tiled for reliable pane arrangement
# Rebalances after each split to prevent "no space for new pane"
# Sessions are named and resumable

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let preset: string = ($cfg.preset? | default "explore")
  let workdir: string = ($cfg.workdir? | default "." | path expand)
  let session: string = match $preset {
    "rl" => "rl-lab"
    _ => $"($preset)-($workdir | path basename)"
  }

  do { ^tmux kill-session -t $session } | complete | ignore
  ^tmux new-session -d -s $session -n main -c $workdir

  let win: string = $"($session):main"

  # Detect pane-base-index
  let base: int = (^tmux show-option -gv pane-base-index | into int)

  match $preset {
    "explore" => { preset_explore $win $workdir $base }
    "compare" => { preset_compare $win $workdir $base }
    "monitor" => { preset_monitor $win $workdir $base }
    "develop" => { preset_develop $win $workdir $base }
    "rl" => { preset_rl $win $workdir $base }
    _ => { print $"Unknown preset: ($preset)" ; return }
  }

  ^tmux attach-session -t $session
}

def add_pane [win: string, workdir: string]: nothing -> nothing {
  ^tmux split-window -t $win -c $workdir
  ^tmux select-layout -t $win tiled
}

def send [win: string, pane: int, cmd: string]: nothing -> nothing {
  ^tmux send-keys -t $"($win).($pane)" $cmd Enter
}

# Explore: 4 panes (2x2 grid)
def preset_explore [win: string, workdir: string, base: int]: nothing -> nothing {
  for _ in 1..3 { add_pane $win $workdir }
}

# Compare: 4 panes (2x2 grid)
def preset_compare [win: string, workdir: string, base: int]: nothing -> nothing {
  for _ in 1..3 { add_pane $win $workdir }
}

# Monitor: 3 panes (main + 2 side)
def preset_monitor [win: string, workdir: string, base: int]: nothing -> nothing {
  for _ in 1..2 { add_pane $win $workdir }
  ^tmux select-layout -t $win main-vertical
}

# Develop: 3 panes (main + 2 side)
def preset_develop [win: string, workdir: string, base: int]: nothing -> nothing {
  for _ in 1..2 { add_pane $win $workdir }
  ^tmux select-layout -t $win main-vertical
}

# RL: 4 panes, all auto-running
# +---------------------------+---------------------------+
# | Shell (init)              | Train / Status            |
# +---------------------------+---------------------------+
# | Registry (just watch)     | Data + Logs               |
# +---------------------------+---------------------------+
def preset_rl [win: string, workdir: string, base: int]: nothing -> nothing {
  for _ in 1..3 { add_pane $win $workdir }

  let b: int = $base
  send $win $b       "just init"
  send $win ($b + 1) "sleep 1; just status"
  send $win ($b + 2) "sleep 1; just watch"
  send $win ($b + 3) "sleep 1; just data"

  ^tmux select-pane -t $"($win).($b)"
}

# List available presets
def "main list" []: nothing -> nothing {
  [
    {name: "explore", description: "Lab work - 4 pane grid", panes: 4}
    {name: "compare", description: "A/B comparison - 4 pane grid", panes: 4}
    {name: "monitor", description: "Dashboard - main + 2 side", panes: 3}
    {name: "develop", description: "Coding - main + 2 side", panes: 3}
    {name: "rl", description: "RL pipeline - shell, status, registry, data", panes: 4}
  ] | print
}
