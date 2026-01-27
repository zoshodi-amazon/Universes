{
  description = "Audio Workbench";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    prelude.url = "path:../../../../Prelude";
  };

  outputs = inputs@{ flake-parts, self, prelude, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        prelude.flakeModules.default
        (import "${self}/Monads/GlobalIO/Context/MonadFlakeIO/index.nix" { inherit self; })
      ];
    };
}
