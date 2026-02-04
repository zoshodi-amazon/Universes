#!/usr/bin/env nu
# Tool Discovery Script
# Usage: discover <domain|tool> [--tool]

def main [
  query: string      # Domain (e.g., "audio") or tool name (e.g., "ffmpeg")
  --tool (-t)        # Search for specific tool instead of domain
] {
  print $"(ansi cyan)═══ Tool Discovery: ($query) ═══(ansi reset)\n"
  
  if $tool {
    discover-tool $query
  } else {
    discover-domain $query
  }
}

def discover-tool [name: string] {
  print $"(ansi yellow)▸ nixpkgs search(ansi reset)"
  let nix_result = (do { nix search nixpkgs $"#($name)" --json } | complete)
  if $nix_result.exit_code == 0 and ($nix_result.stdout | str length) > 2 {
    $nix_result.stdout | from json | transpose k v | each {|r| 
      print $"  ✓ ($r.k): ($r.v.description? | default '')"
    }
  } else {
    print "  ✗ Not in nixpkgs"
  }
  
  print $"\n(ansi yellow)▸ NixOS module check(ansi reset)"
  print $"  → https://search.nixos.org/options?query=($name)"
  
  print $"\n(ansi yellow)▸ home-manager check(ansi reset)"
  print $"  → https://nix-community.github.io/home-manager/options.xhtml#opt-programs.($name).enable"
  
  print $"\n(ansi yellow)▸ Sourcegraph (existing wrappers)(ansi reset)"
  print $"  → https://sourcegraph.com/search?q=lang:nix+($name)+mkEnableOption"
  
  print $"\n(ansi yellow)▸ GitHub(ansi reset)"
  print $"  → https://github.com/search?q=($name)+language:nix&type=code"
  
  print $"\n(ansi yellow)▸ Package meta(ansi reset)"
  let meta = (do { nix eval $"nixpkgs#($name).meta" --json 2>/dev/null } | complete)
  if $meta.exit_code == 0 {
    let m = ($meta.stdout | from json)
    print $"  homepage: ($m.homepage? | default 'n/a')"
    print $"  license: ($m.license?.spdxId? | default 'n/a')"
    print $"  platforms: ($m.platforms? | default [] | length) platforms"
  }
}

def discover-domain [domain: string] {
  print $"(ansi yellow)▸ awesome-($domain)(ansi reset)"
  print $"  → https://github.com/search?q=awesome-($domain)&type=repositories"
  
  print $"\n(ansi yellow)▸ nixpkgs packages in domain(ansi reset)"
  let results = (do { nix search nixpkgs $domain --json 2>/dev/null } | complete)
  if $results.exit_code == 0 and ($results.stdout | str length) > 2 {
    let pkgs = ($results.stdout | from json | transpose k v)
    let count = ($pkgs | length)
    print $"  Found ($count) packages"
    $pkgs | first 10 | each {|r|
      print $"  • ($r.k | split row '.' | last): ($r.v.description? | default '' | str substring 0..60)"
    }
    if $count > 10 { print $"  ... and ($count - 10) more" }
  } else {
    print "  No direct matches"
  }
  
  print $"\n(ansi yellow)▸ NixOS modules in domain(ansi reset)"
  print $"  → https://search.nixos.org/options?query=($domain)"
  
  print $"\n(ansi yellow)▸ Sourcegraph patterns(ansi reset)"
  print $"  → https://sourcegraph.com/search?q=context:global+lang:nix+($domain)+file:default.nix"
  
  print $"\n(ansi yellow)▸ Common tools (search these individually)(ansi reset)"
  let suggestions = match $domain {
    "audio" => ["ffmpeg" "sox" "audacity" "ardour" "lmms" "supercollider"]
    "video" => ["ffmpeg" "mpv" "obs-studio" "kdenlive" "handbrake"]
    "3d" | "cad" => ["blender" "openscad" "freecad" "f3d" "meshlab"]
    "music" => ["ardour" "lmms" "supercollider" "sonic-pi" "musescore"]
    "game" => ["godot" "raylib" "love" "pygame" "bevy"]
    "ml" | "ai" => ["pytorch" "tensorflow" "jax" "scikit-learn" "mlflow"]
    "data" => ["sqlite" "duckdb" "postgresql" "clickhouse" "datasette"]
    "diagram" => ["d2" "graphviz" "plantuml" "mermaid-cli" "drawio"]
    "docs" => ["typst" "pandoc" "mdbook" "sphinx" "asciidoctor"]
    # Sovereignty domains
    "energy" | "power" => ["victron" "mppt" "solar" "battery-management"]
    "comms" | "mesh" => ["meshtastic" "lora" "reticulum" "gnuradio" "direwolf"]
    "intelligence" | "osint" => ["maltego" "spiderfoot" "theHarvester" "sherlock" "ghidra" "radare2"]
    "sigint" | "sdr" => ["gnuradio" "gqrx" "rtl-sdr" "hackrf" "urh"]
    "fabrication" | "maker" => ["openscad" "freecad" "kicad" "prusa-slicer" "cura"]
    "water" => ["water-quality" "filtration" "purification"]
    "food" | "agriculture" => ["farmOS" "growatt" "hydroponics"]
    "medical" | "health" => ["openemr" "gnuhealth" "freediams"]
    "shelter" | "housing" => ["home-assistant" "esphome" "tasmota"]
    "defense" | "security" => ["motion" "zoneminder" "frigate" "shinobi"]
    "trade" | "crypto" => ["monero" "electrum" "bitcoin" "wasabi"]
    "transport" | "navigation" => ["gpsd" "navit" "osmand" "marble"]
    _ => []
  }
  
  # Sovereignty-specific resources
  let sov_resources = match $domain {
    "intelligence" | "osint" => ["https://github.com/jivoi/awesome-osint" "https://osintframework.com"]
    "sigint" | "sdr" => ["https://github.com/luigifcruz/awesome-sdr"]
    "fabrication" => ["https://github.com/ad-si/awesome-3d-printing" "https://oshwa.org"]
    "comms" | "mesh" => ["https://meshtastic.org" "https://reticulum.network"]
    "energy" => ["https://github.com/OpenEnergyMonitor" "https://victronenergy.com/live"]
    _ => []
  }
  if ($sov_resources | length) > 0 {
    print $"\n(ansi yellow)▸ Sovereignty resources(ansi reset)"
    $sov_resources | each {|r| print $"  → ($r)" }
  }
  if ($suggestions | length) > 0 {
    $suggestions | each {|s| print $"  • ($s)" }
    print "\n  Run: discover <tool> --tool"
  }
}
