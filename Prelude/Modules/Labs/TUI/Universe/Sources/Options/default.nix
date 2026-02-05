# Sources - Remote asset repositories per domain
#
# Schema for browsable remote sources (URLs, APIs, repos)
# Domain modules populate with their specific defaults
{ lib, ... }:
{
  options.lab.sources = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Display name";
        };
        url = lib.mkOption {
          type = lib.types.str;
          description = "Base URL or API endpoint";
        };
        type = lib.mkOption {
          type = lib.types.enum [ "http" "git" "api" "s3" ];
          default = "http";
          description = "Source type";
        };
        extensions = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "File extensions to filter";
        };
        tags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Categorization tags";
        };
      };
    });
    default = [];
    description = "Remote asset sources";
  };
}
