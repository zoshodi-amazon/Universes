#!/usr/bin/env nu
# Logs binding: LogsSpec -> Stream
# Tail structured OTEL log output from log directory

def main [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  let log_dir: string = $cfg.telemetry.logDir

  print (gum style --border normal --padding "0 1" "RL Logs")

  if ($log_dir | path exists) {
    # Tail the most recent log file
    let latest: string = (ls $log_dir | sort-by modified -r | first | get name)
    tail -f $latest
  } else {
    print (gum style --foreground 196 $"Log directory not found: ($log_dir)")
  }
}

def "main search" [config_path: string, pattern: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  let log_dir: string = $cfg.telemetry.logDir

  if ($log_dir | path exists) {
    ls $log_dir | get name | each {|f| open $f | lines | where {|l| $l =~ $pattern } } | flatten | print
  }
}
