# NixPersistence Artifact — cross-module storage backend selection
{ lib, ... }:
{
  options.servers.data.persistence = {
    backend = lib.mkOption { type = lib.types.enum [ "local" "s3" "postgres" ]; default = "local"; description = "Storage backend"; };
    local.path = lib.mkOption { type = lib.types.str; default = ".lab/storage.db"; description = "Local SQLite database path"; };
    remote = {
      url = lib.mkOption { type = lib.types.str; default = ""; description = "Remote storage URL"; };
      bucket = lib.mkOption { type = lib.types.str; default = ""; description = "S3 bucket name"; };
      credentials = lib.mkOption { type = lib.types.str; default = ""; description = "Path to credentials"; };
    };
  };
}