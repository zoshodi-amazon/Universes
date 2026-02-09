# Game Env - aggregates Options -> ENV vars
{ config, lib, ... }:
let
  cfg = config.game;
in
{
  config.game.enable = lib.mkDefault true;
}
