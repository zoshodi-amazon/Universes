# Tmux Env
{ config, lib, ... }:
let cfg = config.tmux; in
{
  options.tmux.env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  config.tmux.env = lib.mkIf cfg.enable {
    TMUX_PREFIX = cfg.prefix;
    TMUX_BASE_INDEX = toString cfg.baseIndex;
    TMUX_ESCAPE_TIME = toString cfg.escapeTime;
    TMUX_HISTORY_LIMIT = toString cfg.historyLimit;
    TMUX_MOUSE = lib.boolToString cfg.mouse;
    TMUX_TERMINAL = cfg.terminal;
  };
}
