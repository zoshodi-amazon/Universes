{ lib, ... }:
{
  options.scripts.introspect = {
    enable = lib.mkEnableOption "module options introspection";
  };
}
