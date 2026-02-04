{ lib, ... }:
{
  options.sovereignty.comms = {
    mesh = {
      enable = lib.mkEnableOption "mesh networking";
      protocol = lib.mkOption {
        type = lib.types.enum [ "lora" "meshtastic" "reticulum" "yggdrasil" "cjdns" ];
        default = "meshtastic";
        description = "Mesh protocol";
      };
    };
    burst = {
      enable = lib.mkEnableOption "burst transmission mode";
      maxDuration = lib.mkOption {
        type = lib.types.str;
        default = "500ms";
        description = "Maximum burst duration";
      };
    };
    encryption = lib.mkOption {
      type = lib.types.enum [ "none" "aes256" "chacha20" "otp" ];
      default = "chacha20";
      description = "Encryption type";
    };
    rf = {
      maxPower = lib.mkOption {
        type = lib.types.str;
        default = "100mW";
        description = "Maximum RF power";
      };
      silentPeriods = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Scheduled silent periods (cron format)";
      };
    };
    offline = {
      sms = lib.mkEnableOption "offline SMS via mesh";
      voice = lib.mkEnableOption "offline voice via mesh";
      data = lib.mkEnableOption "offline data sync";
    };
  };
}
