{ lib, ... }: {
  options.legal.privacy = {
    piiHandling = lib.mkOption {
      type = lib.types.enum [ "none" "anonymized" "encrypted" "prohibited" ];
      default = "prohibited";
      description = "How PII may be handled in this environment";
    };
    dataClassification = lib.mkOption {
      type = lib.types.enum [ "public" "internal" "confidential" "restricted" ];
      default = "internal";
      description = "Default data classification level";
    };
  };
}
