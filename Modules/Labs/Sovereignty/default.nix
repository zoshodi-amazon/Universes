# Sovereignty — global instantiation
# Wires Types (type space) + Monads (CLI binary) into the flake
# Produces default.json (serialized config for Lean CLI)
{ lib, config, inputs, ... }:
let
  cfg = config.sovereignty;
in
{
  # Defaults (bounded fixed points for all params)
  config.sovereignty = {
    mode = lib.mkDefault "base";
    bootstrap.seed = lib.mkDefault "knowledge";
    opsec = {
      physical.enable = lib.mkDefault true;
      signal.enable = lib.mkDefault true;
      digital.enable = lib.mkDefault true;
      social.enable = lib.mkDefault false;
      financial.enable = lib.mkDefault true;
      temporal.enable = lib.mkDefault false;
      legal.enable = lib.mkDefault false;
    };
  };

  config.perSystem = { pkgs, system, ... }:
  let
    isLinux = builtins.elem system [ "x86_64-linux" "aarch64-linux" ];
    sovConfig = pkgs.writeText "default.json" (builtins.toJSON cfg);
  in {
    # Serialized config for CLI binaries
    packages.sovereignty-config = sovConfig;

    # Dev shell
    devShells.sovereignty = pkgs.mkShell {
      name = "sovereignty";
      packages = with pkgs; [
        ollama
        wireshark
      ] ++ lib.optionals isLinux [
        kiwix-tools
        meshtasticd
        gnuradio
        ghidra
      ];
      shellHook = ''
        export SOV_CONFIG_PATH="${sovConfig}"
        export SOVEREIGNTY_MODE="${cfg.mode}"
        echo "Sovereignty shell - mode: $SOVEREIGNTY_MODE"
      '';
    };
  };
}
