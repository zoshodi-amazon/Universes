# Env: 1-1 mapping from options
{ config, lib, ... }:
let cfg = config.nixvim; in
{
  config.nixvim.env = lib.mkIf cfg.enable {
    NVIM_COLORSCHEME = cfg.colorscheme;
    NVIM_LEADER = cfg.leader;
    NVIM_LINE_NUMBERS = lib.boolToString cfg.lineNumbers;
    NVIM_RELATIVE_NUMBERS = lib.boolToString cfg.relativeNumbers;
    NVIM_TAB_WIDTH = toString cfg.tabWidth;
  };
}
