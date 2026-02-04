{ config, lib, ... }:
{
  config = lib.mkIf config.scripts.scaffold.enable {
    scripts.scaffold.enable = lib.mkDefault true;
  };
}
