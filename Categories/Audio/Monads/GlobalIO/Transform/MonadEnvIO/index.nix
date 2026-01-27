# MonadEnvIO: pure tether
{ pkgs, self }:

let
  inherit (import "${self}/Types/Transform/EnvIO/Outputs/index.nix" { inherit pkgs; }) packages env shellHook;
in
pkgs.mkShell { inherit packages env shellHook; }
