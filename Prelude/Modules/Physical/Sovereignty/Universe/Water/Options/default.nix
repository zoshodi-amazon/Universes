{ lib, ... }:
{
  options.sovereignty.water = {
    source = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "rain" "well" "surface" "atmospheric" "recycled" ]);
      default = [ "rain" ];
    };
    purification = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "filter" "uv" "boil" "distill" "reverse-osmosis" "chemical" ]);
      default = [ "filter" "uv" ];
    };
    storage.capacity = lib.mkOption { type = lib.types.str; default = "100L"; };
    signature.visual = lib.mkOption {
      type = lib.types.enum [ "visible" "camouflaged" "concealed" ];
      default = "visible";
    };
  };
}
