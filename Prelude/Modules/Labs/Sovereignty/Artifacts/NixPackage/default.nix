# NixPackage — uv-managed Python derivation for sovereignty CLIs
# Assembles all Monad scripts into a single package with deps pinned via uv
{ ... }:
{
  perSystem = { pkgs, ... }:
  let
    python = pkgs.python313;
    sov = pkgs.stdenv.mkDerivation {
      pname = "sov";
      version = "0.1.0";
      src = ../../Monads;
      nativeBuildInputs = [ pkgs.makeWrapper pkgs.uv python ];
      buildPhase = ''
        export HOME=$TMPDIR
        export UV_CACHE_DIR=$TMPDIR/uv-cache
        uv venv $out/venv --python ${python}/bin/python
        uv pip install --python $out/venv/bin/python \
          pydantic pydantic-settings typer rich \
          cadquery numpy trimesh \
          pvlib pandas scipy \
          matplotlib plotly
      '';
      installPhase = ''
        mkdir -p $out/bin $out/lib/monads

        # Copy all monad scripts
        for d in M* IOM*; do
          if [ -f "$d/default.py" ]; then
            cp "$d/default.py" "$out/lib/monads/''${d}.py"
          fi
        done

        # Create CLI entry points for each monad
        for d in M* IOM*; do
          if [ -f "$d/default.py" ]; then
            name=$(echo "$d" | sed 's/^IOM/io-/;s/^M//;' | sed 's/\([A-Z]\)/-\L\1/g' | sed 's/^-//')
            makeWrapper $out/venv/bin/python $out/bin/$name \
              --add-flags "$out/lib/monads/''${d}.py"
          fi
        done
      '';
    };
  in {
    packages.sov = sov;
  };
}
