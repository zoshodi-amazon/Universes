# Mail — global instantiation
# Wires NixMail Artifact + IOMNixMail Monad into flake.modules.homeManager.mail
{ config, lib, ... }:
let
  cfg = config.mail;
  mkAccountConfig = name: acct: {
    address = acct.email;
    realName = name;
    userName = acct.email;
    flavor = if acct.host == "outlook.office365.com" then "outlook.office365.com" else "plain";
    imap = {
      host = acct.host;
      port = 993;
    };
    smtp = {
      host = acct.sendHost;
      port = if acct.sendHost == "smtp-mail.outlook.com" then 587 else 465;
      tls.useStartTls = acct.sendHost == "smtp-mail.outlook.com";
    };
    passwordCommand = {
      "sops" = "cat \${config.sops.secrets.\"mail-${name}-password\".path}";
      "keyring" = "secret-tool lookup mail ${name}";
      "command" = "true";
    }.${acct.auth};
    himalaya.enable = true;
    primary = name == cfg.defaultAccount;
  };
in
{
  config.mail.enable = lib.mkDefault true;

  config.flake.modules.homeManager.mail = { pkgs, ... }: {
    config = lib.mkIf cfg.enable {
      programs.himalaya.enable = true;
      accounts.email.accounts = lib.mapAttrs mkAccountConfig cfg.accounts;
      home.packages = [ pkgs.posting ];
    };
  };
}
