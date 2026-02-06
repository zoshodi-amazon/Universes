# Machine Options - All questions in one place
{ lib, ... }:
let
  userSubmodule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Username";
      };
      home = lib.mkOption {
        type = lib.types.str;
        description = "Home configuration name (maps to homeConfigurations.<name>)";
      };
      groups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "wheel" "networkmanager" ];
        description = "User groups";
      };
      initialPassword = lib.mkOption {
        type = lib.types.str;
        default = "changeme";
        description = "Initial password (change on first login)";
      };
    };
  };

  machineSubmodule = lib.types.submodule {
    options = {
      # Identity - What is this machine called?
      identity.hostname = lib.mkOption {
        type = lib.types.str;
        description = "Machine hostname";
      };
      
      # Target - What architecture?
      target.arch = lib.mkOption {
        type = lib.types.enum [ "x86_64" "aarch64" ];
        default = "x86_64";
        description = "Target architecture";
      };
      
      # Format - How do I deploy it?
      format.type = lib.mkOption {
        type = lib.types.enum [ "iso" "vm" "sd-image" "raw-efi" "oci" ];
        default = "vm";
        description = "Deployment format";
      };
      
      # Persistence - What survives reboot? Where?
      persistence = {
        strategy = lib.mkOption {
          type = lib.types.enum [ "full" "impermanent" "ephemeral" ];
          default = "full";
          description = "Persistence strategy";
        };
        device = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Block device or label for persistent storage";
        };
        paths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "/var/log" "/var/lib/nixos" "/etc/NetworkManager/system-connections" ];
          description = "Directories to persist";
        };
      };
      
      # Users - Who can use this machine?
      users = lib.mkOption {
        type = lib.types.listOf userSubmodule;
        default = [];
        description = "Users on this machine (each maps to a homeConfiguration)";
      };
    };
  };
in
{
  options.machines = lib.mkOption {
    type = lib.types.attrsOf machineSubmodule;
    default = {};
    description = "Machine definitions";
  };
}
