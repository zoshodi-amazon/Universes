# IOWorkspacePhase — devShells + labs
{ config, lib, ... }:
let
  base = builtins.fromJSON (builtins.readFile ./default.json);
  local =
    if builtins.pathExists ./local.json then
      builtins.fromJSON (builtins.readFile ./local.json)
    else
      { };
  cfg = lib.recursiveUpdate base local;
  sov = cfg.sovereignty;
in
{
  config.perSystem =
    { pkgs, system, ... }:
    let
      isLinux = builtins.elem system [
        "x86_64-linux"
        "aarch64-linux"
      ];
      sovConfig = pkgs.writeText "default.json" (builtins.toJSON sov);
    in
    {
      packages.sovereignty-config = sovConfig;
      devShells.sovereignty = pkgs.mkShell {
        name = "sovereignty";
        packages =
          with pkgs;
          [
            ollama
            wireshark
          ]
          ++ lib.optionals isLinux [
            kiwix-tools
            meshtasticd
            gnuradio
            ghidra
          ];
        shellHook = ''
          export SOV_CONFIG_PATH="${sovConfig}"
          export SOVEREIGNTY_MODE="${sov.mode}"
          echo "Sovereignty shell - mode: $SOVEREIGNTY_MODE"
        '';
      };
    };
}
