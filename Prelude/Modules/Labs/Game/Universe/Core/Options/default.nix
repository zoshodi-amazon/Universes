{ lib, ... }:
{
  options.game = {
    enable = lib.mkEnableOption "Game design lab";
    projectDir = lib.mkOption {
      type = lib.types.str;
      default = ".lab";
    };
  };
}
