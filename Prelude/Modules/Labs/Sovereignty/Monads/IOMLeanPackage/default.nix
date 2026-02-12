# sov CLI derivation — Lean 4 via lean4-nix
# Compiles Sovereignty ADT folds into native binary
{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }:
  let
    lean4-nix = inputs.lean4-nix;
    leanPkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [ (lean4-nix.readToolchainFile ./lean-toolchain) ];
    };
    lake2nix = leanPkgs.callPackage lean4-nix.lake {};
    sov = lake2nix.mkPackage {
      name = "sov";
      src = ./.;
    };
  in {
    packages.sov = sov;
  };
}
