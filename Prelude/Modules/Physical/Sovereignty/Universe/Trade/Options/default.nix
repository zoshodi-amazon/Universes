{ lib, ... }:
{
  options.sovereignty.trade = {
    methods = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "barter" "crypto" "cash" "commodity" "service" ]);
      default = [ "barter" "crypto" ];
    };
    crypto = {
      enable = lib.mkEnableOption "cryptocurrency";
      coins = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "btc" "xmr" "zec" ]);
        default = [ "xmr" ];
        description = "Privacy-focused by default";
      };
      coldStorage = lib.mkEnableOption "cold storage";
    };
    supplyChain = {
      verification = lib.mkEnableOption "supply chain verification";
      redundancy = lib.mkOption { type = lib.types.int; default = 2; description = "Number of independent sources"; };
    };
    signature.financial = lib.mkOption {
      type = lib.types.enum [ "traceable" "pseudonymous" "anonymous" ];
      default = "pseudonymous";
    };
  };
}
