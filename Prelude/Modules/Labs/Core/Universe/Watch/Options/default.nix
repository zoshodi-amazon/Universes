{ lib, ... }:
{
  options.lab.watch = {
    patterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "File patterns to watch";
      example = [ "*.wav" "*.mp3" ];
    };
    command = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Command to run on file change";
    };
    debounce = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Debounce delay in milliseconds";
    };
  };
}
