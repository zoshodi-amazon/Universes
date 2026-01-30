{ lib, ... }: {
  options.nix-settings = {
    enable = lib.mkEnableOption "Nix daemon optimizations";
    gc = {
      automatic = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable automatic garbage collection";
      };
      interval = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "GC interval (daily, weekly, monthly)";
      };
      olderThan = lib.mkOption {
        type = lib.types.str;
        default = "7d";
        description = "Delete generations older than this";
      };
    };
    optimise = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable store optimisation (hard-linking)";
    };
    maxJobs = lib.mkOption {
      type = lib.types.either lib.types.int (lib.types.enum [ "auto" ]);
      default = "auto";
      description = "Max parallel build jobs";
    };
    cores = lib.mkOption {
      type = lib.types.either lib.types.int (lib.types.enum [ 0 ]);
      default = 0;
      description = "Cores per build (0 = all)";
    };
  };
}
