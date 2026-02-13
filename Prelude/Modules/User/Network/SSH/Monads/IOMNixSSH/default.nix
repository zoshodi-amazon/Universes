# IOMNixSSH Monad — enables itself
{ lib, ... }:
{
  config.ssh.enable = lib.mkDefault true;
}
