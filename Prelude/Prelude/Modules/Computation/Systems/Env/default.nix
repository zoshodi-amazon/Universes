# Systems Env
{ config, lib, ... }:
let
  microvm = config.nixosSystems.microvm;
in
{
  options.nixosSystems.env = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };
  config.nixosSystems.env = lib.mkIf microvm.enable {
    MICROVM_MEMORY = toString microvm.memory;
    MICROVM_VCPU = toString microvm.vcpu;
  };
}
