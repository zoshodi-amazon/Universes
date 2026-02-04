{ lib, ... }: {
  options.legal.employment = {
    workDevice = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this is an employer-owned device";
    };
    employer = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Current employer name";
    };
    jurisdiction = lib.mkOption {
      type = lib.types.str;
      default = "US-TX";
      description = "Primary employment jurisdiction (country-state)";
    };
    ipAssignment = lib.mkOption {
      type = lib.types.enum [ "all" "related" "worktime" "none" ];
      default = "related";
      description = "IP assignment scope per employment agreement";
    };
  };
}
