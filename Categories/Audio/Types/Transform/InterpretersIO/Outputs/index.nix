# InterpretersIO: audio scripting interpreters
{ config, lib, pkgs, ... }:
{
  config.interpreters = lib.mkForce (with pkgs; [
    bash
    python3
    jq
  ]);
}
