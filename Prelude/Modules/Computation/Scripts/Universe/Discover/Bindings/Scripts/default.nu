#!/usr/bin/env nu
# Discover - Capability-based tool discovery
# Interprets discover Options
# Strongly typed throughout

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let action: string = ($cfg.action? | default "help")

  match $action {
    "search-nixpkgs" => { search_nixpkgs $cfg.query }
    "search-repos" => { search_repos $cfg.query }
    "score" => { score_candidates $cfg }
    "freeze" => { freeze_selection $cfg }
    "help" => { print_help }
    _ => { print_help }
  }
}

def print_help []: nothing -> nothing {
  print "Discover - Capability-based tool discovery"
  print ""
  print "Actions:"
  print "  search-nixpkgs  Search nixpkgs for packages"
  print "  search-repos    Search code repositories (codegraph)"
  print "  score           Score candidates against capabilities"
  print "  freeze          Output frozen selection"
  print ""
  print "Example:"
  print '  nu default.nu ''{"action": "search-nixpkgs", "query": "audio visualizer"}'''
}

def search_nixpkgs [query: string]: nothing -> nothing {
  print (gum style --border normal --padding "0 1" $"Searching nixpkgs: ($query)")
  let result: string = (do { ^nix search nixpkgs $query --json } | complete).stdout
  if ($result | is-empty) {
    print "No results found"
    return
  }
  let packages: record = ($result | from json)
  let names: list<string> = ($packages | columns)
  for name in $names {
    let pkg: record = ($packages | get $name)
    let desc: string = ($pkg.description? | default "")
    print $"  ($name): ($desc | str substring 0..60)"
  }
}

def search_repos [query: string]: nothing -> nothing {
  print (gum style --border normal --padding "0 1" $"Searching repos: ($query)")
  # Codegraph search - lightweight binding
  # Could use: https://sourcegraph.com/search or GitHub API
  print "Repository search not yet implemented"
  print "Candidates: sourcegraph API, GitHub search API"
}

def score_candidates [cfg: record]: nothing -> nothing {
  let capabilities: list = ($cfg.capabilities? | default [])
  let candidates: list = ($cfg.candidates? | default [])
  
  if ($capabilities | is-empty) {
    print "No capabilities defined"
    return
  }
  if ($candidates | is-empty) {
    print "No candidates to score"
    return
  }
  
  let total_weight: float = ($capabilities | get weight | math sum)
  
  let scores: list = ($candidates | each { |candidate|
    let matched_weight: float = ($capabilities | where { |cap|
      $candidate.capabilities | any { |c| $c == $cap.name }
    } | get weight | math sum)
    
    let score: float = ($matched_weight / $total_weight)
    let satisfies_required: bool = ($capabilities | where required == true | all { |cap|
      $candidate.capabilities | any { |c| $c == $cap.name }
    })
    
    {
      name: $candidate.name
      score: $score
      satisfies_required: $satisfies_required
      source: $candidate.source
    }
  })
  
  let ranked: list = ($scores | sort-by score --reverse)
  
  print (gum style --border normal --padding "0 1" "Candidate Scores")
  for item in $ranked {
    let status: string = (if $item.satisfies_required { "OK" } else { "MISSING REQUIRED" })
    print $"  ($item.name): ($item.score | into string -d 2) [($status)]"
  }
}

def freeze_selection [cfg: record]: nothing -> nothing {
  let selected: list<string> = ($cfg.selected? | default [])
  if ($selected | is-empty) {
    print "No selection to freeze"
    return
  }
  
  print (gum style --border normal --padding "0 1" "Frozen Selection")
  for tool in $selected {
    print $"  - ($tool)"
  }
  print ""
  print "Add to Options/default.nix:"
  print ($selected | to json)
}
