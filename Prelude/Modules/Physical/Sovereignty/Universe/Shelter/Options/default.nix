{ lib, ... }:
{
  options.sovereignty.shelter = {
    type = lib.mkOption {
      type = lib.types.enum [ "tent" "vehicle" "structure" "underground" "natural" ];
      default = "structure";
    };
    mobility = lib.mkOption {
      type = lib.types.enum [ "portable" "relocatable" "fixed" ];
      default = "fixed";
    };
    climate = {
      heating = lib.mkOption { type = lib.types.enum [ "none" "passive" "active" ]; default = "passive"; };
      cooling = lib.mkOption { type = lib.types.enum [ "none" "passive" "active" ]; default = "passive"; };
    };
    signature = {
      thermal = lib.mkOption { type = lib.types.enum [ "unmanaged" "insulated" "masked" ]; default = "unmanaged"; };
      visual = lib.mkOption { type = lib.types.enum [ "visible" "camouflaged" "concealed" ]; default = "visible"; };
      acoustic = lib.mkOption { type = lib.types.enum [ "unmanaged" "dampened" "silent" ]; default = "unmanaged"; };
    };
  };
}
