#!/usr/bin/env nu
# Session - Workspace state management
# Interprets lab.session Options

def main [config_json: string] {
  let cfg = ($config_json | from json)
  let path = ($cfg.path? | default ".lab/session.json")
  let action = ($cfg.action? | default "load")

  match $action {
    "init" => { init_session $path }
    "load" => { load_session $path }
    "save" => { save_session $path $cfg }
    "set-current" => { set_current $path $cfg.id }
    "push" => { push_transform $path $cfg.transform }
    "pop" => { pop_transform $path }
    "set-mode" => { set_mode $path $cfg.mode }
    _ => { print $"Unknown action: ($action)" }
  }
}

def default_session [] {
  {
    current: null,
    stack: [],
    undoPosition: 0,
    mode: "browse"
  }
}

def init_session [path: string] {
  let dir = ($path | path dirname)
  if not ($dir | path exists) { mkdir $dir }
  default_session | save -f $path
  print $"Initialized session: ($path)"
}

def load_session [path: string] {
  if ($path | path exists) {
    open $path
  } else {
    default_session
  }
}

def save_session [path: string, cfg: record] {
  let dir = ($path | path dirname)
  if not ($dir | path exists) { mkdir $dir }
  
  let session = {
    current: ($cfg.current? | default null),
    stack: ($cfg.stack? | default []),
    undoPosition: ($cfg.undoPosition? | default 0),
    mode: ($cfg.mode? | default "browse")
  }
  $session | save -f $path
  print $"Saved session: ($path)"
}

def set_current [path: string, id: string] {
  let session = (load_session $path)
  $session | update current $id | save -f $path
  print $"Current asset: ($id)"
}

def push_transform [path: string, transform: record] {
  let session = (load_session $path)
  let new_stack = ($session.stack | append $transform)
  $session | update stack $new_stack | save -f $path
  print $"Pushed transform: ($transform.type)"
}

def pop_transform [path: string] {
  let session = (load_session $path)
  if ($session.stack | is-empty) {
    print "Stack is empty"
    return
  }
  let popped = ($session.stack | last)
  let new_stack = ($session.stack | drop 1)
  $session | update stack $new_stack | save -f $path
  print $"Popped transform: ($popped.type)"
}

def set_mode [path: string, mode: string] {
  let session = (load_session $path)
  $session | update mode $mode | save -f $path
  print $"Mode: ($mode)"
}
