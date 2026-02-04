{ lib, ... }:
{
  options.sovereignty.energy = {
    generation = {
      types = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "solar" "wind" "hydro" "thermal" "manual" "fuel" ]);
        default = [ "solar" ];
        description = "Power generation methods";
      };
      capacity = lib.mkOption {
        type = lib.types.str;
        default = "100W";
        description = "Target generation capacity";
      };
    };
    storage = {
      capacity = lib.mkOption {
        type = lib.types.str;
        default = "1kWh";
        description = "Storage capacity";
      };
      chemistry = lib.mkOption {
        type = lib.types.enum [ "lifepo4" "li-ion" "lead-acid" "supercap" "mechanical" ];
        default = "lifepo4";
        description = "Storage chemistry/type";
      };
    };
    distribution.voltage = lib.mkOption {
      type = lib.types.enum [ "5V" "12V" "24V" "48V" "120V" "240V" ];
      default = "12V";
      description = "Primary distribution voltage";
    };
    signature = {
      thermal = lib.mkOption {
        type = lib.types.enum [ "unmanaged" "passive" "active" ];
        default = "unmanaged";
        description = "Thermal signature management";
      };
      acoustic = lib.mkOption {
        type = lib.types.enum [ "unmanaged" "dampened" "silent" ];
        default = "unmanaged";
        description = "Acoustic signature management";
      };
      visual = lib.mkOption {
        type = lib.types.enum [ "visible" "camouflaged" "concealed" ];
        default = "visible";
        description = "Visual signature management";
      };
    };
  };
}
