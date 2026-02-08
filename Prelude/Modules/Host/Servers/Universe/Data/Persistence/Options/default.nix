# Persistence Options - cross-module storage backend selection
{ lib, ... }:
{
  options.servers.data.persistence = {
    backend = lib.mkOption {
      type = lib.types.enum [ "local" "s3" "postgres" ];
      default = "local";
      description = "Storage backend for module-local data";
    };
    local.path = lib.mkOption {
      type = lib.types.str;
      default = ".lab/storage.db";
      description = "Local SQLite database path (per-module)";
    };
    remote = {
      url = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Remote storage URL (s3://... or postgres://...)";
      };
      bucket = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "S3 bucket name (for s3 backend)";
      };
      credentials = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Path to credentials file or secret";
      };
    };
  };
}
