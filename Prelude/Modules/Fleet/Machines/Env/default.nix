# Machines Env - Define machine configurations
{ ... }:
{
  config.machines.sovereignty = {
    identity.hostname = "sovereignty";
    target.arch = "x86_64";
    format.type = "iso";
    persistence.strategy = "impermanent";
    persistence.device = "/dev/disk/by-label/NIXOS_PERSIST";
    users = [
      { name = "zoshodi"; home = "darwin"; }  # maps to homeConfigurations.darwin
    ];
  };
}
