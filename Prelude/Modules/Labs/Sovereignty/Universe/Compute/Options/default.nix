{ lib, ... }:
{
  options.sovereignty.compute = {
    architecture = lib.mkOption {
      type = lib.types.enum [ "riscv64" "aarch64" "x86_64" ];
      default = "aarch64";
      description = "Target architecture";
    };
    openness = lib.mkOption {
      type = lib.types.enum [ "full" "partial" "pragmatic" ];
      default = "partial";
      description = "Hardware openness level";
    };
    airgap.enable = lib.mkEnableOption "air-gapped operation";
    disposable.enable = lib.mkEnableOption "disposable/burner capability";
    knowledge = {
      static = {
        enable = lib.mkEnableOption "static knowledge base (kiwix, offline wikis)";
        sources = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "wikipedia" "wikibooks" "stackexchange" ];
          description = "Static knowledge sources";
        };
      };
      llm = {
        enable = lib.mkEnableOption "local LLM";
        model = lib.mkOption {
          type = lib.types.str;
          default = "llama-7b";
          description = "LLM model";
        };
      };
      structured = {
        enable = lib.mkEnableOption "structured queryable databases";
        domains = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "plants" "chemicals" "electronics" "medical" ];
          description = "Structured data domains";
        };
      };
    };
  };
}
