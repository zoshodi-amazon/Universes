# ObjectStore Options
{ lib, ... }:
{
  options.servers.data.objectStore = {
    enable = lib.mkEnableOption "S3-compatible object storage";
    
    backend = lib.mkOption {
      type = lib.types.enum [ "minio" "garage" ];
      default = "minio";
      description = "Object storage backend";
    };
    
    port = lib.mkOption {
      type = lib.types.port;
      default = 9000;
      description = "S3 API port";
    };
    
    consolePort = lib.mkOption {
      type = lib.types.port;
      default = 9001;
      description = "Web console port";
    };
    
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/minio/data";
      description = "Data directory";
    };
    
    rootUser = lib.mkOption {
      type = lib.types.str;
      default = "minioadmin";
      description = "Root username";
    };
    
    rootPassword = lib.mkOption {
      type = lib.types.str;
      default = "minioadmin";
      description = "Root password (use secrets in production)";
    };
  };
}
