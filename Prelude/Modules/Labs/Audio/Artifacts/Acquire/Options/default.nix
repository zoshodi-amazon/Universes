{ lib, ... }:
{
  options.audio.acquire = {
    source = lib.mkOption {
      type = lib.types.enum [ "url" "file" "generate" ];
      default = "file";
      description = "Source type";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "URL to fetch (for source = url)";
    };
    input = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Input file path (for source = file)";
    };
    generate = lib.mkOption {
      type = lib.types.submodule {
        options = {
          waveform = lib.mkOption {
            type = lib.types.enum [ "sine" "square" "noise" ];
            default = "sine";
          };
          frequency = lib.mkOption {
            type = lib.types.int;
            default = 440;
          };
          duration = lib.mkOption {
            type = lib.types.str;
            default = "1";
          };
        };
      };
      default = {};
      description = "Generation params (for source = generate)";
    };
    output = lib.mkOption {
      type = lib.types.str;
      default = "./audio/output.wav";
      description = "Output path";
    };
  };
}
