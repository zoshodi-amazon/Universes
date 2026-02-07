# rl CLI derivation - uv-managed Python with sb3/gymnasium/pandas
# Uses uv to install deps into a venv, wraps main.py as CLI
{ ... }:
{
  perSystem = { pkgs, ... }:
  let
    python = pkgs.python313;
    rl = pkgs.stdenv.mkDerivation {
      pname = "rl";
      version = "0.3.0";
      src = ./.;
      nativeBuildInputs = [ pkgs.makeWrapper pkgs.uv python ];
      buildPhase = ''
        export HOME=$TMPDIR
        export UV_CACHE_DIR=$TMPDIR/uv-cache
        uv venv $out/venv --python ${python}/bin/python
        uv pip install --python $out/venv/bin/python \
          stable-baselines3 gymnasium pandas
      '';
      installPhase = ''
        mkdir -p $out/bin $out/lib
        cp main.py $out/lib/main.py
        makeWrapper $out/venv/bin/python $out/bin/rl \
          --add-flags "$out/lib/main.py"
      '';
    };
  in {
    packages.rl = rl;
  };
}
