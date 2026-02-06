# Stable-Baselines3 derivation (if nixpkgs version breaks)
{ lib, ... }:
{
  # config.perSystem = { pkgs, ... }:
  # let python = pkgs.python311; in {
  #   packages.sb3 = python.pkgs.buildPythonPackage rec {
  #     pname = "stable-baselines3";
  #     version = "2.2.1";
  #     ...
  #   };
  # };
}
