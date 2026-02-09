{ lib, ... }:
{
  options.game.asset = {
    backend = lib.mkOption {
      type = lib.types.enum [ "local" "sqlite" ];
      default = "local";
    };
    storePath = lib.mkOption {
      type = lib.types.str;
      default = ".lab/assets";
    };
    catalogDb = lib.mkOption {
      type = lib.types.str;
      default = ".lab/assets.db";
    };
  };
}
