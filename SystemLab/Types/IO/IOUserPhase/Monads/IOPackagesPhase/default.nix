# IOPackagesPhase (QGP) — corePackages
# Note: corePackages are consumed by IOMainPhase, declared here
{ config, lib, ... }:
let
  base = builtins.fromJSON (builtins.readFile ../../default.json);
  local =
    if builtins.pathExists ../../local.json then
      builtins.fromJSON (builtins.readFile ../../local.json)
    else
      { };
  cfg = lib.recursiveUpdate base local;
in
{
  config.home.corePackages = cfg.corePackages;
}
