# Acquire Options - fetch media from URLs
{ lib, ... }:
{
  options.audio.acquire = {
    url = lib.mkOption { type = lib.types.str; default = ""; };
    format = lib.mkOption { type = lib.types.enum [ "best" "mp3" "wav" "flac" "opus" ]; default = "best"; };
    outputDir = lib.mkOption { type = lib.types.str; default = "./downloads"; };
  };
}
