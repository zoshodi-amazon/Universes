# NixCloud — typed option space for AWS CLI profiles
{ lib, ... }:
{
  options.cloud = {
    enable = lib.mkEnableOption "AWS CLI profile management";
    defaultRegion = lib.mkOption {
      type = lib.types.str;
      default = "us-east-1";
      description = "Default AWS region";
    };
    defaultOutput = lib.mkOption {
      type = lib.types.enum [ "json" "text" "table" "yaml" ];
      default = "json";
      description = "Default CLI output format";
    };
    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = {};
      description = "Named AWS profiles (written to ~/.aws/config)";
    };
  };
}
