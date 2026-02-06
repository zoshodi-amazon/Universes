# rl CLI derivation - frozen Python with sb3/gymnasium
{ ... }:
{
  perSystem = { pkgs, ... }:
  let
    python = pkgs.python311;
    rl = python.pkgs.buildPythonApplication {
      pname = "rl";
      version = "0.1.0";
      format = "other";
      src = ./main.py;
      propagatedBuildInputs = with python.pkgs; [
        stable-baselines3
        gymnasium
        torch
        numpy
      ];
      installPhase = ''
        mkdir -p $out/bin $out/lib
        cp $src $out/lib/main.py
        cat > $out/bin/rl << EOF
        #!${python.interpreter}
        exec(open("$out/lib/main.py").read())
        EOF
        chmod +x $out/bin/rl
      '';
    };
  in {
    packages.rl = rl;
  };
}
