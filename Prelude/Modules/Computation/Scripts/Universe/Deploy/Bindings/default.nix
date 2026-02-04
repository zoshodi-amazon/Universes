{ config, lib, ... }:
{
  config = lib.mkIf config.scripts.deploy.enable {
    scripts.deploy.enable = lib.mkDefault true;
  };
}
