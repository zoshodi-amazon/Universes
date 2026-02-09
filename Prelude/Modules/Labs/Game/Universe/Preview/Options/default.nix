{ lib, ... }:
{
  options.game.preview = {
    method = lib.mkOption {
      type = lib.types.enum [ "terminal" "browser" ];
      default = "terminal";
    };
    watchExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "png" "aseprite" "blend" "json" ];
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8090;
    };
  };
}
