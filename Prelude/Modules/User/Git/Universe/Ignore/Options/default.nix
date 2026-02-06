# Git Ignore Options
{ lib, ... }:
{
  options.git.ignores = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Global gitignore patterns";
  };
}
