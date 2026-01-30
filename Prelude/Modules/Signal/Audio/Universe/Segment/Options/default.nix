# Segment Options - split/trim/concat
{ lib, ... }:
{
  options.audio.segment = {
    trimStart = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    trimEnd = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    splitAt = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    fadeIn = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    fadeOut = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
  };
}
