{ lib, config, ... }:
let
  cfg = config.sovereignty;
in
{
  config = {
    sovereignty = {
      mode = lib.mkDefault "base";
      bootstrap.seed = lib.mkDefault "knowledge";
      fabrication.tier = lib.mkDefault "assembly";
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

    perSystem = { pkgs, system, ... }: 
    let
      isLinux = builtins.elem system [ "x86_64-linux" "aarch64-linux" ];
    in {
      devShells.sovereignty = pkgs.mkShell {
        name = "sovereignty";
        packages = with pkgs; [
          # Core tools available in all modes
          ollama          # local LLM
          wireshark       # protocol analysis
        ] ++ lib.optionals isLinux [
          kiwix-tools     # offline knowledge (linux only)
          meshtasticd     # mesh comms
          gnuradio        # SDR
          ghidra          # RE
        ];
        shellHook = ''
          export SOVEREIGNTY_MODE="${cfg.mode}"
          export SOVEREIGNTY_BOOTSTRAP="${cfg.bootstrap.seed}"
          echo "Sovereignty shell - mode: $SOVEREIGNTY_MODE"
        '';
      };
    };
  };
}
