# IOTerminalPhase (Liquid) — tmux, kitty
{ config, lib, ... }:
let
  base = builtins.fromJSON (builtins.readFile ../../default.json);
  local =
    if builtins.pathExists ../../local.json then
      builtins.fromJSON (builtins.readFile ../../local.json)
    else
      { };
  cfg = lib.recursiveUpdate base local;
  t = cfg.tmux;
  k = cfg.kitty;
in
{
  config.flake.modules.homeManager.tmux = lib.mkIf t.enable {
    programs.tmux = {
      enable = true;
      prefix = t.prefix;
      baseIndex = t.baseIndex;
      escapeTime = t.escapeTime;
      historyLimit = t.historyLimit;
      mouse = t.mouse;
      terminal = t.terminal;
      extraConfig = ''
        set -ga terminal-overrides ",xterm-256color:Tc"
        set -ga terminal-overrides ",*256col*:Tc"
        set -g set-clipboard on
        set -g renumber-windows on
        set -g pane-base-index 1
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        unbind '"'
        unbind %
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"
        bind t display-popup -E -w 80% -h 80%
        bind g display-popup -E -w 80% -h 80% "lazygit"
        bind f display-popup -E -w 80% -h 80% "fzf"
        set -g pane-border-style fg=colour238
        set -g pane-active-border-style fg=colour250
        set -g status-position top
        set -g status-style bg=colour235,fg=colour250
        set -g status-justify centre
        set -g status-left '#{?client_prefix,#[bg=colour2]#[fg=colour0] PREFIX #[default],} #S '
        set -g status-right " %H:%M "
        setw -g window-status-format " #I:#W "
        setw -g window-status-current-format "#[bg=colour240,fg=colour255] #I:#W "
        ${t.extraConfig}
      '';
    };
  };
  config.flake.modules.homeManager.kitty = lib.mkIf k.enable {
    programs.kitty = {
      enable = true;
      font.name = k.fontName;
      font.size = k.fontSize;
      themeFile = k.theme;
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
      }
      // k.settings;
    };
  };
}
