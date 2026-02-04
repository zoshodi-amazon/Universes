{ config, lib, ... }:
{
  config = lib.mkIf config.scripts.introspect.enable {
    scripts.introspect.enable = lib.mkDefault true;
  };
}
