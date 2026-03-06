# IOPackagesPhase (QGP) — corePackages
# Note: corePackages are consumed by IOMainPhase, declared here
{ config, lib, ... }:
let
  cfg = builtins.fromJSON (builtins.readFile ../../default.json);
in
{
  config.home.corePackages = cfg.corePackages;
}
