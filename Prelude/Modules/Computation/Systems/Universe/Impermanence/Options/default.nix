{ lib, ... }:
{
  options.nixosSystems.impermanence = {
    enable = lib.mkEnableOption "impermanence (ephemeral root)";
    strategy = lib.mkOption {
      type = lib.types.enum [ "tmpfs" "btrfs" ];
      default = "btrfs";
      description = "Impermanence strategy";
    };
    persistPath = lib.mkOption {
      type = lib.types.str;
      default = "/persistent";
      description = "Path to persistent storage";
    };
    directories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
      ];
      description = "Directories to persist";
    };
    files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/etc/machine-id" ];
      description = "Files to persist";
    };
  };
}
