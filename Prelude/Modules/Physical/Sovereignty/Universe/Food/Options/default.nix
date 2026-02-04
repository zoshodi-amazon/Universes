{ lib, ... }:
{
  options.sovereignty.food = {
    acquisition = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "forage" "hunt" "fish" "cultivate" "trade" "store" ]);
      default = [ "store" "cultivate" ];
    };
    preservation = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "dry" "smoke" "salt" "ferment" "freeze" "can" "vacuum" ]);
      default = [ "dry" "vacuum" ];
    };
    cultivation = {
      method = lib.mkOption {
        type = lib.types.enum [ "soil" "hydroponic" "aquaponic" "aeroponic" ];
        default = "soil";
      };
      scale = lib.mkOption {
        type = lib.types.enum [ "personal" "family" "community" ];
        default = "personal";
      };
    };
    signature.thermal = lib.mkOption {
      type = lib.types.enum [ "unmanaged" "passive" "active" ];
      default = "unmanaged";
    };
  };
}
