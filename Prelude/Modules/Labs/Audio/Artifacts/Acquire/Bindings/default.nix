{ config, lib, ... }:
{
  config = lib.mkIf (config.audio.acquire.source != "") {
    # Wiring handled by interpreter
  };
}
