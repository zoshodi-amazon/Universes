# ObjectStore Bindings - generates podman.stacks entry
{ config, lib, ... }:
let
  cfg = config.servers.data.objectStore;
  
  # Backend-specific image mapping
  images = {
    minio = "minio/minio:latest";
    garage = "dxflrs/garage:latest";
  };
in
{
  config.servers.podman = lib.mkIf cfg.enable {
    enable = true;
    stacks.objectstore = {
      image = images.${cfg.backend};
      ports = [
        "${toString cfg.port}:9000"
        "${toString cfg.consolePort}:9001"
      ];
      volumes = [
        "${cfg.dataDir}:/data"
      ];
      environment = {
        MINIO_ROOT_USER = cfg.rootUser;
        MINIO_ROOT_PASSWORD = cfg.rootPassword;
      };
      autoStart = true;
    };
  };
}
