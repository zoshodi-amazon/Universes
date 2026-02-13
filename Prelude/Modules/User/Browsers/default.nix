# Browsers — global instantiation
# Hardened Firefox with arkenfox-style settings, always-max
{ config, lib, ... }:
let
  cfg = config.browser;
  hardenedSettings = {
    # Telemetry
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "browser.ping-centre.telemetry" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    # Crash reports
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
    # Pocket / sponsored
    "extensions.pocket.enabled" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.default.sites" = "";
    # Fingerprinting / tracking
    "privacy.resistFingerprinting" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
    "privacy.trackingprotection.cryptomining.enabled" = true;
    "privacy.trackingprotection.fingerprinting.enabled" = true;
    # WebRTC leak prevention
    "media.peerconnection.enabled" = false;
    "media.peerconnection.ice.default_address_only" = true;
    "media.peerconnection.ice.no_host" = true;
    # HTTPS-only
    "dom.security.https_only_mode" = true;
    "dom.security.https_only_mode_ever_enabled" = true;
    # Form autofill
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.creditCards.enabled" = false;
    "signon.rememberSignons" = false;
    # DNS over HTTPS
    "network.trr.mode" = 2;
    # Misc hardening
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
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableFormHistory = true;
        DontCheckDefaultBrowser = true;
        SearchBar = "unified";
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = { installation_mode = "force_installed"; install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"; };
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = { installation_mode = "force_installed"; install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi"; };
          "addon@darkreader.org" = { installation_mode = "force_installed"; install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi"; };
        };
      };
      profiles.hardened = {
        isDefault = true;
        search.default = cfg.search.default;
        settings = hardenedSettings;
      };
    };
  };
}
