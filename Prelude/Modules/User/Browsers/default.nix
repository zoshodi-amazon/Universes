# Browsers — global instantiation
# Hardened Firefox with arkenfox-style settings, always-max
# Settings are profile-level only — no source rebuild needed
{ config, lib, ... }:
let
  cfg = config.browser;
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
in
{
  config.flake.modules.homeManager.browser = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.hardened = {
        isDefault = true;
        search.default = cfg.search.default;
        settings = hardenedSettings;
      };
    };
  };
}
