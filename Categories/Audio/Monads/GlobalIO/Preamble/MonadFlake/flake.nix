{
  description = "Audio Workbench";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = (import "${self}/Types/Space/SystemsIO/Outputs/index.nix").systems;
      
      perSystem = { pkgs, ... }: {
        devShells.default = import "${self}/Monads/GlobalIO/Transform/MonadEnvIO/index.nix" { inherit pkgs self; };
      };
    };
}
