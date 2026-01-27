# DeployRS Options
{ lib, ... }:
{
  options.deploy = {
    enable = lib.mkEnableOption "deploy-rs remote deployment";
    sshUser = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "SSH user for deployment";
    };
    nodes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          hostname = lib.mkOption { type = lib.types.str; };
          profiles = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                path = lib.mkOption { type = lib.types.str; };
                user = lib.mkOption { type = lib.types.str; default = "root"; };
              };
            });
            default = {};
          };
        };
      });
      default = {};
      description = "Deployment nodes";
    };
  };
}
