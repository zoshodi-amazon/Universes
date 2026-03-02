# NixDirenv Artifact
{ lib, ... }:
{
  options.shell.direnv = {
    enable = lib.mkEnableOption "direnv";
    nix-direnv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable"; };
  };
}
