{ config, lib, ... }:
let env = config.shell.env; in
{
  # Shared aliases - single source of truth
  config.shell.aliases = {
    k = "kiro-cli";
    vi = "nvim";
    ll = "ls -la"; la = "ls -la"; l = "ls -l";
    b = "cd .. && ls"; ".." = "cd .."; "..." = "cd ../..";
    hm = "home-manager"; hms = "home-manager switch";
    nr = "nix registry"; nf = "nix flake"; nfc = "nix flake check"; nd = "nix develop";
    gs = "git status"; ga = "git add"; gc = "git commit";
    gca = "git commit --amend --no-edit"; gl = "git log --oneline"; gd = "git diff";
    txn = "tmux new-session -s"; txl = "tmux ls"; txk = "tmux kill-session -t";
    discover = "nu ~/repos/Universes/Prelude/Modules/Computation/Scripts/Universe/Discover/Bindings/Scripts/default.nu";
  };

  config.shell.fish = {
    enable = lib.mkDefault true;
    aliases = config.shell.aliases;
    paths = [ env.TOOLBOX_BIN env.LOCAL_BIN env.NIX_PROFILE ];
    interactiveShellInit = ''
      if test -f ~/.nix-profile/etc/profile.d/nix.sh
        bass source ~/.nix-profile/etc/profile.d/nix.sh
      end
    '';
  };

  config.shell.nushell = {
    enable = lib.mkDefault true;
    aliases = config.shell.aliases;
    paths = [ env.TOOLBOX_BIN env.LOCAL_BIN env.NIX_PROFILE ];
    envExtra = ''
      $env.EDITOR = "${env.EDITOR}"
      $env.VISUAL = "${env.VISUAL}"
    '';
  };

  config.shell.zsh = {
    enable = lib.mkDefault true;
    aliases = config.shell.aliases;
    paths = [ env.TOOLBOX_BIN env.LOCAL_BIN env.NIX_PROFILE ];
    initExtra = ''
      if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        source ~/.nix-profile/etc/profile.d/nix.sh
      fi
    '';
  };

  config.shell.direnv.enable = lib.mkDefault true;

  # Shared home-manager config
  config.flake.modules.homeManager.shell = {
    home.sessionVariables = {
      EDITOR = env.EDITOR;
      VISUAL = env.VISUAL;
      KEYTIMEOUT = toString env.KEYTIMEOUT;
    };
    programs.starship.enable = true;
  };
}
