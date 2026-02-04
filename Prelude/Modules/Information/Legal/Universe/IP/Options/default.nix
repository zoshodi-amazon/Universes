{ lib, ... }: {
  options.legal.ip = {
    personalProjects = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of personal project paths/names";
    };
    workProjects = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of work project paths/names";
    };
    boundaryMode = lib.mkOption {
      type = lib.types.enum [ "strict" "warn" "permissive" ];
      default = "warn";
      description = "How strictly to enforce IP boundaries";
    };
  };
}
