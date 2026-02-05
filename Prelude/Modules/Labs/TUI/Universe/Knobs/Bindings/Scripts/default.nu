#!/usr/bin/env nu
# Dials - Orthogonal coefficient management
# Interprets lab.dials Options

def main [config_json: string] {
  let cfg = ($config_json | from json)
  let action = ($cfg.action? | default "list")

  match $action {
    "list" => { list_dials $cfg }
    "get" => { get_dial $cfg $cfg.name }
    "set" => { set_dial $cfg $cfg.name $cfg.value }
    "normalize" => { normalize $cfg $cfg.name $cfg.native }
    "denormalize" => { denormalize $cfg $cfg.name $cfg.normalized }
    _ => { print $"Unknown action: ($action)" }
  }
}

def list_dials [cfg: record] {
  let defs = ($cfg.definitions? | default [])
  let vals = ($cfg.values? | default {})
  
  $defs | each { |d|
    let norm = ($vals | get -o $d.name | default $d.normalized)
    let native = (denorm $d $norm)
    {
      name: $d.name,
      label: $d.label,
      normalized: $norm,
      native: $native,
      unit: $d.unit
    }
  }
}

def get_dial [cfg: record, name: string] {
  let defs = ($cfg.definitions? | default [])
  let vals = ($cfg.values? | default {})
  
  let d = ($defs | where name == $name | first)
  let norm = ($vals | get -o $name | default $d.normalized)
  let native = (denorm $d $norm)
  
  { normalized: $norm, native: $native, unit: $d.unit }
}

def set_dial [cfg: record, name: string, value: float] {
  # Returns updated values map
  let vals = ($cfg.values? | default {})
  $vals | upsert $name $value
}

def normalize [cfg: record, name: string, native: float] {
  let defs = ($cfg.definitions? | default [])
  let d = ($defs | where name == $name | first)
  norm $d $native
}

def denormalize [cfg: record, name: string, normalized: float] {
  let defs = ($cfg.definitions? | default [])
  let d = ($defs | where name == $name | first)
  denorm $d $normalized
}

# Normalize: domain-native -> 0.0-1.0
def norm [dial: record, native: float] {
  let scale = ($dial.scale? | default "linear")
  match $scale {
    "linear" => { ($native - $dial.min) / ($dial.max - $dial.min) }
    "log" => { 
      let log_min = ($dial.min | math log 10)
      let log_max = ($dial.max | math log 10)
      let log_val = ($native | math log 10)
      ($log_val - $log_min) / ($log_max - $log_min)
    }
    "exp" => { (($native - $dial.min) / ($dial.max - $dial.min)) | math sqrt }
    _ => { ($native - $dial.min) / ($dial.max - $dial.min) }
  }
}

# Denormalize: 0.0-1.0 -> domain-native
def denorm [dial: record, normalized: float] {
  let scale = ($dial.scale? | default "linear")
  match $scale {
    "linear" => { $dial.min + ($normalized * ($dial.max - $dial.min)) }
    "log" => {
      let log_min = ($dial.min | math log 10)
      let log_max = ($dial.max | math log 10)
      let log_val = $log_min + ($normalized * ($log_max - $log_min))
      10 ** $log_val
    }
    "exp" => { $dial.min + (($normalized ** 2) * ($dial.max - $dial.min)) }
    _ => { $dial.min + ($normalized * ($dial.max - $dial.min)) }
  }
}
