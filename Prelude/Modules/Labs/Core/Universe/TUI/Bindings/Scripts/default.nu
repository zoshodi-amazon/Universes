#!/usr/bin/env nu
# Lab TUI - Interactive workstation using gum
# Interprets lab.tui Options

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let domain: string = ($cfg.domain? | default "audio")
  let justfile: string = ($cfg.justfile? | default $"Modules/Labs/($domain | str capitalize)/justfile")
  
  loop {
    let choice = (gum choose "Browse Library" "Add Asset" "Transform" "Analyze" "Play" "Quit" | str trim)
    
    match $choice {
      "Browse Library" => { browse_library }
      "Add Asset" => { add_asset }
      "Transform" => { transform_menu $justfile }
      "Analyze" => { analyze_menu $justfile }
      "Play" => { play_current $justfile }
      "Quit" => { break }
      _ => { break }
    }
  }
}

def browse_library []: nothing -> nothing {
  let db_path = ".lab/library.json"
  if not ($db_path | path exists) {
    gum style --foreground 196 "No library found. Add an asset first."
    return
  }
  
  let assets = (open $db_path | get assets)
  if ($assets | is-empty) {
    gum style --foreground 196 "Library is empty."
    return
  }
  
  let names = ($assets | get name)
  let selected = ($names | str join "\n" | gum filter --placeholder "Select asset..." | str trim)
  
  if ($selected | is-not-empty) {
    let asset = ($assets | where name == $selected | first)
    gum style --border normal --padding "1 2" $"ID: ($asset.id)\nName: ($asset.name)\nPath: ($asset.path)\nSource: ($asset.source)"
    
    # Set as current
    { current: $asset.id } | save -f ".lab/session.json"
    gum style --foreground 82 $"Set as current: ($asset.name)"
  }
}

def add_asset []: nothing -> nothing {
  let source_type = (gum choose "URL" "Local File" "Generate Tone" | str trim)
  
  match $source_type {
    "URL" => {
      let url = (gum input --placeholder "Enter URL..." | str trim)
      if ($url | is-empty) { return }
      let name = (gum input --placeholder "Asset name..." | str trim)
      if ($name | is-empty) { return }
      
      let output = $".lab/assets/($name | str replace ' ' '_').wav"
      mkdir .lab/assets
      gum spin --spinner dot --title "Fetching..." -- curl -sL $url -o $output
      
      nu Universe/Library/Bindings/Scripts/default.nu $'{"action": "add", "name": "($name)", "path": "($output)", "source": "url"}'
    }
    "Local File" => {
      let path = (gum input --placeholder "File path..." | str trim)
      if ($path | is-empty) { return }
      let name = (gum input --placeholder "Asset name..." --value ($path | path basename) | str trim)
      
      nu Universe/Library/Bindings/Scripts/default.nu $'{"action": "add", "name": "($name)", "path": "($path)", "source": "file"}'
    }
    "Generate Tone" => {
      let freq = (gum input --placeholder "Frequency (Hz)..." --value "440" | str trim)
      let duration = (gum input --placeholder "Duration (seconds)..." --value "1" | str trim)
      let name = (gum input --placeholder "Asset name..." --value $"tone_($freq)hz" | str trim)
      
      let output = $".lab/assets/($name).wav"
      mkdir .lab/assets
      gum spin --spinner dot --title "Generating..." -- ffmpeg -y -f lavfi -i $"sine=frequency=($freq):duration=($duration)" $output
      
      nu Universe/Library/Bindings/Scripts/default.nu $'{"action": "add", "name": "($name)", "path": "($output)", "source": "generated"}'
    }
    _ => { }
  }
}

def transform_menu [justfile: string]: nothing -> nothing {
  let current = (get_current_asset)
  if $current == null {
    gum style --foreground 196 "No asset selected. Browse library first."
    return
  }
  
  let transform = (gum choose "Pitch Shift" "Time Stretch" "Highpass Filter" "Lowpass Filter" "Normalize" "Back" | str trim)
  
  match $transform {
    "Pitch Shift" => {
      let semitones = (gum input --placeholder "Semitones (+/-)..." --value "0" | str trim)
      let output = $"($current.path | path parse | get stem)_pitch($semitones).wav"
      gum spin --spinner dot --title "Processing..." -- just -f $justfile pitch $current.path $semitones $output
      gum style --foreground 82 $"Created: ($output)"
    }
    "Time Stretch" => {
      let factor = (gum input --placeholder "Factor (0.5=half, 2=double)..." --value "1.0" | str trim)
      let output = $"($current.path | path parse | get stem)_stretch($factor).wav"
      gum spin --spinner dot --title "Processing..." -- just -f $justfile stretch $current.path $factor $output
      gum style --foreground 82 $"Created: ($output)"
    }
    "Highpass Filter" => {
      let freq = (gum input --placeholder "Cutoff frequency (Hz)..." --value "200" | str trim)
      let output = $"($current.path | path parse | get stem)_hp($freq).wav"
      gum spin --spinner dot --title "Processing..." -- just -f $justfile highpass $current.path $freq $output
      gum style --foreground 82 $"Created: ($output)"
    }
    "Lowpass Filter" => {
      let freq = (gum input --placeholder "Cutoff frequency (Hz)..." --value "5000" | str trim)
      let output = $"($current.path | path parse | get stem)_lp($freq).wav"
      # Would need lowpass recipe in Audio justfile
      gum style --foreground 214 "Lowpass not yet implemented"
    }
    "Normalize" => {
      let output = $"($current.path | path parse | get stem)_normalized.wav"
      # Would need normalize recipe
      gum style --foreground 214 "Normalize not yet implemented"
    }
    _ => { }
  }
}

def analyze_menu [justfile: string]: nothing -> nothing {
  let current = (get_current_asset)
  if $current == null {
    gum style --foreground 196 "No asset selected. Browse library first."
    return
  }
  
  gum spin --spinner dot --title "Analyzing..." -- just -f $justfile analyze $current.path .lab/analysis
  gum style --foreground 82 "Analysis saved to .lab/analysis/"
}

def play_current [justfile: string]: nothing -> nothing {
  let current = (get_current_asset)
  if $current == null {
    gum style --foreground 196 "No asset selected. Browse library first."
    return
  }
  
  gum style --foreground 212 $"Playing: ($current.name)"
  just -f $justfile play $current.path
}

def get_current_asset []: nothing -> any {
  if not (".lab/session.json" | path exists) { return null }
  if not (".lab/library.json" | path exists) { return null }
  
  let session = (open ".lab/session.json")
  let current_id = ($session.current? | default null)
  if $current_id == null { return null }
  
  let assets = (open ".lab/library.json" | get assets)
  let matches = ($assets | where id == $current_id)
  if ($matches | is-empty) { null } else { $matches | first }
}
