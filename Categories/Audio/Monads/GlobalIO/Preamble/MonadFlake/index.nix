# MonadFlake: constructs the flake from Types
let
  inputs = import ../../../Types/Preamble/FlakeIO/Inputs;
  inherit (import ../../../Types/Space/SystemsIO/Outputs) systems;
  inherit (import ../../../Types/Preamble/FlakeIO/Outputs) devShells;
in
{
  inherit (inputs) description;
  
  inputs = {
    inherit (inputs) nixpkgs;
  };

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in { default = import ../../Transform/MonadEnvIO { inherit pkgs; }; }
      );
    };
}
