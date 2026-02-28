# NixPackage — uv2nix declarative Python build for sovereignty CLIs
{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }:
  let
    workspace = inputs.uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };

    overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };

    python = pkgs.python313;

    pythonBase = pkgs.callPackage inputs.pyproject-nix.build.packages { inherit python; };

    pythonSet = pythonBase.overrideScope (
      pkgs.lib.composeManyExtensions [
        inputs.pyproject-build-systems.overlays.wheel
        overlay
      ]
    );

    sovEnv = pythonSet.mkVirtualEnv "sov-env" workspace.deps.default;
  in {
    packages.sov = sovEnv;

    devShells.sovereignty = pkgs.mkShell {
      packages = [ sovEnv pkgs.uv ];
      env = {
        UV_NO_SYNC = "1";
        UV_PYTHON = pythonSet.python.interpreter;
        UV_PYTHON_DOWNLOADS = "never";
      };
      shellHook = ''
        unset PYTHONPATH
      '';
    };
  };
}
