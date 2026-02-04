{ lib, ... }: {
  options.legal.licensing = {
    allowedLicenses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "MIT" "Apache-2.0" "BSD-3-Clause" "ISC" ];
      description = "OSS licenses permitted for use";
    };
    copyleftPolicy = lib.mkOption {
      type = lib.types.enum [ "allow" "review" "prohibit" ];
      default = "review";
      description = "Policy for copyleft licenses (GPL, AGPL)";
    };
    claRequired = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether CLA approval needed for OSS contributions";
    };
  };
}
