# IOCommsPhase (Plasma) — browser, mail, AI, cloud
{ config, lib, ... }:
let
  base = builtins.fromJSON (builtins.readFile ../../default.json);
  local =
    if builtins.pathExists ../../local.json then
      builtins.fromJSON (builtins.readFile ../../local.json)
    else
      { };
  cfg = lib.recursiveUpdate base local;
  brow = cfg.browser;
  mail = cfg.mail;
  ai = cfg.ai;
  cloud = cfg.cloud;
  hardenedSettings = {
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "browser.ping-centre.telemetry" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
    "extensions.pocket.enabled" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.default.sites" = "";
    "privacy.resistFingerprinting" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
    "privacy.trackingprotection.cryptomining.enabled" = true;
    "privacy.trackingprotection.fingerprinting.enabled" = true;
    "media.peerconnection.enabled" = false;
    "media.peerconnection.ice.default_address_only" = true;
    "media.peerconnection.ice.no_host" = true;
    "dom.security.https_only_mode" = true;
    "dom.security.https_only_mode_ever_enabled" = true;
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.creditCards.enabled" = false;
    "signon.rememberSignons" = false;
    "network.trr.mode" = 2;
    "geo.enabled" = false;
    "network.prefetch-next" = false;
    "network.dns.disablePrefetch" = true;
    "browser.urlbar.speculativeConnect.enabled" = false;
    "browser.send_pings" = false;
  };
  providerSettings = lib.optionalAttrs (ai.provider == "amazon-bedrock") {
    provider.amazon-bedrock.options = {
      region = ai.region;
      profile = ai.profile;
    }
    // lib.optionalAttrs (ai.endpoint != "") { endpoint = ai.endpoint; };
  };
in
{
  config.flake.modules.homeManager.browser = lib.mkIf brow.enable {
    programs.firefox = {
      enable = true;
      profiles.hardened = {
        isDefault = true;
        search.default = brow.searchDefault;
        settings = hardenedSettings;
      };
    };
  };
  config.flake.modules.homeManager.ai = lib.mkIf ai.enable {
    programs.opencode = {
      enable = true;
      settings = providerSettings // ai.extraSettings;
      rules = lib.concatStringsSep "\n" ai.rules;
    };
  };
  config.flake.modules.homeManager.cloud = lib.mkIf cloud.enable {
    programs.awscli = {
      enable = true;
      settings = {
        default = {
          region = cloud.defaultRegion;
          output = cloud.defaultOutput;
        };
      }
      // cloud.profiles;
    };
  };
  config.flake.modules.homeManager.mail = lib.mkIf mail.enable (
    { pkgs, config, ... }:
    {
      programs.himalaya.enable = true;
      accounts.email.accounts = lib.mapAttrs (name: acct: {
        address = acct.email;
        realName = name;
        userName = acct.email;
        flavor = if acct.host == "outlook.office365.com" then "outlook.office365.com" else "plain";
        imap = lib.mkIf (acct.host != "outlook.office365.com") {
          host = acct.host;
          port = 993;
        };
        smtp = lib.mkIf (acct.host != "outlook.office365.com") {
          host = acct.sendHost;
          port = if acct.sendHost == "smtp-mail.outlook.com" then 587 else 465;
          tls.useStartTls = acct.sendHost == "smtp-mail.outlook.com";
        };
        passwordCommand =
          {
            "sops" = "cat \${config.sops.secrets.\"mail-${name}-password\".path}";
            "keyring" = "secret-tool lookup mail ${name}";
            "command" = "true";
          }
          .${acct.auth};
        himalaya.enable = true;
        primary = name == mail.defaultAccount;
      }) mail.accounts;
    }
  );
}
