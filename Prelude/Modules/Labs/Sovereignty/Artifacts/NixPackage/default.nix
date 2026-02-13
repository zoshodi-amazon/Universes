# NixPackage artifact — assembles Lean source tree from Artifacts + Monads, builds via lean4-nix
# The pullback: composes all canonical sources into a Lake-compatible layout
{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }:
  let
    lean4-nix = inputs.lean4-nix;
    leanPkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [ (lean4-nix.readToolchainFile ../LeanToolchain/lean-toolchain) ];
    };
    lake2nix = leanPkgs.callPackage lean4-nix.lake {};

    # Assemble Lake project from Artifacts (types) + Monads (folds)
    sovSrc = pkgs.runCommand "sov-src" {} ''
      mkdir -p $out/Sovereignty

      # Lake project config (from Artifacts)
      cp ${../LeanLake/lakefile.lean} $out/lakefile.lean
      cp ${../LeanToolchain/lean-toolchain} $out/lean-toolchain

      # Canonical types (from Artifacts) -> Sovereignty/Types.lean
      # Concatenate all Lean artifacts into single compilable module
      cat \
        ${../LeanSignature/default.lean} \
        ${../LeanOpsec/default.lean} \
        ${../LeanItem/default.lean} \
        ${../LeanEnergy/default.lean} \
        ${../LeanWater/default.lean} \
        ${../LeanFood/default.lean} \
        ${../LeanShelter/default.lean} \
        ${../LeanMedical/default.lean} \
        ${../LeanComms/default.lean} \
        ${../LeanCompute/default.lean} \
        ${../LeanIntelligence/default.lean} \
        ${../LeanDefense/default.lean} \
        ${../LeanTransport/default.lean} \
        ${../LeanTrade/default.lean} \
        ${../LeanFabrication/default.lean} \
        ${../LeanSurvival/default.lean} \
        ${../LeanInfrastructure/default.lean} \
        ${../LeanOperations/default.lean} \
        ${../LeanExpansion/default.lean} \
        ${../LeanDomains/default.lean} \
        ${../LeanSovGlobal/default.lean} \
        ${../LeanSovereignty/default.lean} \
        > $out/Sovereignty/Types.lean

      # Monads (folds) -> Sovereignty/Queries.lean + Sovereignty/Effects.lean
      cp ${../../Monads/MLeanSovereignty/default.lean} $out/Sovereignty/Queries.lean
      cp ${../../Monads/IOMLeanSovereignty/default.lean} $out/Sovereignty/Effects.lean

      # CLI entry point
      cp ${../../Monads/IOMLeanMain/default.lean} $out/Main.lean
    '';

    sov = lake2nix.mkPackage {
      name = "sov";
      src = sovSrc;
    };
  in {
    packages.sov = sov;
  };
}
