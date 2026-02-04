{ lib, ... }:
{
  options.sovereignty.modes.urban = {
    coverIdentity = lib.mkOption { type = lib.types.str; default = ""; description = "Cover identity/legend"; };
    blendLevel = lib.mkOption {
      type = lib.types.enum [ "tourist" "resident" "local" "native" ];
      default = "resident";
    };
    infrastructureUse = lib.mkOption {
      type = lib.types.enum [ "none" "minimal" "selective" "full" ];
      default = "selective";
      description = "How much existing infrastructure to use";
    };
    devices = {
      burner = lib.mkEnableOption "burner devices for cover";
      real = lib.mkEnableOption "real identity devices (separate)";
    };
  };
}
