{ lib, ... }:
# Env/ aggregates Universe/*/Options → ENV vars (1-1 mapping)
# These become the source of truth for shell configuration
{
  options.shell.env = {
    # Core paths
    TOOLBOX_BIN = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.toolbox/bin";
      description = "AWS BuilderHub toolbox binary path";
    };

    LOCAL_BIN = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.local/bin";
      description = "Local user binaries";
    };

    NIX_PROFILE = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.nix-profile/bin";
      description = "Nix profile binaries";
    };

    # Editor
    EDITOR = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Default editor";
    };

    VISUAL = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Visual editor";
    };

    # Shell behavior
    KEYTIMEOUT = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "Key timeout for vi mode";
    };

    # History
    HISTSIZE = lib.mkOption {
      type = lib.types.int;
      default = 10000;
      description = "History size";
    };
  };

  options.shell.aliases = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Shared shell aliases across all shell types";
  };
}
