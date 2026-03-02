# IOMNixOpencode Monad — enables itself
{ lib, ... }:
{
  config.ai.opencode = {
    enable = lib.mkDefault true;
    profile = lib.mkDefault "conduit";
  };
}
