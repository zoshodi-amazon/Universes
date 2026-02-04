{ lib, ... }:
{
  options.sovereignty.fabrication = {
    tier = lib.mkOption {
      type = lib.types.enum [ "assembly" "component" "material" ];
      default = "assembly";
      description = "Fabrication depth";
    };
    capabilities = {
      printing3d = lib.mkEnableOption "3D printing";
      cnc = lib.mkEnableOption "CNC machining";
      pcb = lib.mkEnableOption "PCB fabrication";
      welding = lib.mkEnableOption "welding/metalwork";
      woodwork = lib.mkEnableOption "woodworking";
      textiles = lib.mkEnableOption "textile/sewing";
      chemistry = lib.mkEnableOption "chemical synthesis";
      casting = lib.mkEnableOption "metal casting";
    };
    materials = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "plastic" "metal" "wood" "ceramic" "composite" "electronic" ]);
      default = [ "plastic" ];
    };
  };
}
