#!/usr/bin/env nu
# Smoke test: verify each Options -> Bindings adjunction produces ENV vars
# Run inside `nix develop .#rl` where shellHook exports all RL_* vars

# Feature -> required ENV vars (the adjunction contract)
let features: record = {
  Data: [RL_DATA_PROVIDER RL_DATA_TICKERS RL_DATA_INTERVAL RL_DATA_START_DATE RL_DATA_END_DATE RL_DATA_INDICATORS RL_DATA_DIR]
  Env: [RL_ENV_ID RL_ENV_N_ENVS]
  Observation: [RL_OBS_NORMALIZE RL_OBS_CLIP_RANGE]
  Feature: []
  Agent: [RL_AGENT_ALGORITHM RL_AGENT_POLICY RL_AGENT_NET_ARCH]
  Train: [RL_TRAIN_TIMESTEPS RL_TRAIN_LR RL_TRAIN_BATCH_SIZE RL_TRAIN_GAMMA]
  Eval: [RL_EVAL_EPISODES RL_EVAL_DETERMINISTIC]
  Infer: [RL_INFER_DEVICE]
  Execution: [RL_EXEC_PROVIDER RL_EXEC_MAX_POSITION]
  Store: [RL_STORE_BACKEND RL_STORE_MODEL_DIR RL_STORE_CHECKPOINT_FREQ]
  Registry: [RL_REGISTRY_ENABLE RL_REGISTRY_DB_PATH RL_REGISTRY_MIN_REWARD RL_REGISTRY_MIN_EPISODES RL_REGISTRY_KEEP_TOP_N]
  Telemetry: [RL_TELEMETRY_DB_PATH RL_TELEMETRY_LOG_DIR RL_TELEMETRY_LOG_LEVEL]
  Metrics: [RL_METRICS_ENABLE]
  Traces: [RL_TRACES_ENABLE]
  Logs: [RL_LOGS_ENABLE RL_LOGS_LEVEL]
}

def check_feature [name: string, vars: list<string>]: nothing -> record {
  if ($vars | is-empty) {
    {name: $name, pass: true, missing: [], note: "alias of Agent"}
  } else {
    let env_keys: list<string> = ($env | columns)
    let missing: list<string> = ($vars | where {|v| $v not-in $env_keys })
    {name: $name, pass: ($missing | is-empty), missing: $missing, note: ""}
  }
}

def render_result [r: record]: nothing -> string {
  let pad: string = ("." | fill -c '.' -w (16 - ($r.name | str length)))
  if $r.pass {
    let label: string = (gum style --foreground 82 "PASS")
    let suffix: string = if ($r.note | is-empty) { "" } else { ["(" $r.note ")"] | str join "" }
    ["  " $label "  " $r.name " " $pad $suffix] | str join ""
  } else {
    let label: string = (gum style --foreground 196 "FAIL")
    let missing_str: string = ($r.missing | str join ", ")
    ["  " $label "  " $r.name " " $pad " missing: " $missing_str] | str join ""
  }
}

def main [feature?: string]: nothing -> nothing {
  print (gum style --border normal --padding "0 1" "RL Smoke Test")
  print ""

  let results: list<record> = if ($feature != null) {
    let name: string = ($feature | str capitalize)
    if ($name not-in ($features | columns)) {
      print (gum style --foreground 196 "Unknown feature")
      ["Available: " ($features | columns | str join ", ")] | str join "" | print
      return
    }
    let vars: list<string> = ($features | get $name)
    [(check_feature $name $vars)]
  } else {
    $features | columns | each {|name|
      let vars: list<string> = ($features | get $name)
      check_feature $name $vars
    }
  }

  for r in $results {
    let line: string = (render_result $r)
    print $line
  }

  let total: int = ($results | length)
  let passed: int = ($results | where pass | length)
  let failed: int = ($total - $passed)

  print ""
  if ($failed == 0) {
    print (gum style --foreground 82 ([$passed "/" $total " passed"] | str join ""))
  } else {
    print (gum style --foreground 196 ([$passed "/" $total " passed, " $failed " failed"] | str join ""))
  }
}
