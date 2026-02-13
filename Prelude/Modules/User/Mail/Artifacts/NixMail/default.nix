# NixMail Artifact — typed option space for CLI mail accounts
# 6 bounded params per account. No nulls. No loose strings.
{ lib, ... }:
{
  options.mail = {
    enable = lib.mkEnableOption "CLI mail management via himalaya";
    defaultAccount = lib.mkOption {
      type = lib.types.str;
      default = "outlook";
      description = "Primary account name (must match a key in accounts)";
    };
    accounts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          email = lib.mkOption {
            type = lib.types.str;
            description = "Account email address";
          };
          backend = lib.mkOption {
            type = lib.types.enum [ "imap" "maildir" "notmuch" ];
            default = "imap";
            description = "Read backend protocol";
          };
          sendBackend = lib.mkOption {
            type = lib.types.enum [ "smtp" "sendmail" ];
            default = "smtp";
            description = "Send backend protocol";
          };
          host = lib.mkOption {
            type = lib.types.str;
            default = "outlook.office365.com";
            description = "IMAP/read host";
          };
          sendHost = lib.mkOption {
            type = lib.types.str;
            default = "smtp-mail.outlook.com";
            description = "SMTP/send host";
          };
          auth = lib.mkOption {
            type = lib.types.enum [ "sops" "keyring" "command" ];
            default = "sops";
            description = "Auth method — sops: decrypt via sops-nix, keyring: OS keychain, command: custom CLI";
          };
        };
      });
      default = {};
      description = "Named mail accounts (each a bounded 6-dimensional metric space)";
    };
  };
}
