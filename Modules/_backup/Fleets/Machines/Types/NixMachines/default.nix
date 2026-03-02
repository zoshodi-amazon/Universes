# NixMachines Artifact — typed option space for machine definitions
{ lib, ... }:
let
  userSubmodule = lib.types.submodule {
    options = {
      name = lib.mkOption { type = lib.types.str; description = "Username"; };
      home = lib.mkOption { type = lib.types.str; description = "Home configuration name"; };
      groups = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "wheel" "networkmanager" ]; description = "Groups"; };
      initialPassword = lib.mkOption { type = lib.types.str; default = "changeme"; description = "Initial password"; };
    };
  };
  machineSubmodule = lib.types.submodule {
    options = {
      identity.hostname = lib.mkOption { type = lib.types.str; description = "Machine hostname"; };
      target.arch = lib.mkOption { type = lib.types.enum [ "x86_64" "aarch64" ]; default = "x86_64"; description = "Arch"; };
      format.type = lib.mkOption { type = lib.types.enum [ "iso" "vm" "sd-image" "raw-efi" "oci" "microvm" ]; default = "vm"; description = "Type"; };
      disk = {
        layout = lib.mkOption { type = lib.types.enum [ "standard" "custom" "none" ]; default = "none"; description = "Layout"; };
        device = lib.mkOption { type = lib.types.str; default = "/dev/sda"; description = "Device"; };
        persistLabel = lib.mkOption { type = lib.types.str; default = "NIXOS_PERSIST"; description = "Persist label"; };
      };
      persistence = {
        strategy = lib.mkOption { type = lib.types.enum [ "full" "impermanent" "ephemeral" ]; default = "full"; description = "Strategy"; };
        device = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; description = "Device"; };
        paths = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "/var/log" "/var/lib/nixos" "/etc/NetworkManager/system-connections" ]; description = "Paths"; };
      };
      users = lib.mkOption { type = lib.types.listOf userSubmodule; default = []; description = "Users"; };
    };
  };
in
{
  options.machines = lib.mkOption { type = lib.types.attrsOf machineSubmodule; default = {}; description = "Machine definitions"; };
}
