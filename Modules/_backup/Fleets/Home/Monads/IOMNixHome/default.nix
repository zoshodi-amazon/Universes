# IOMNixHome Monad — enables defaults + core packages
{ lib, ... }:
{
  config.home.darwin.enable = lib.mkDefault true;
  config.home.cloudDev.enable = lib.mkDefault true;
  config.home.corePackages = [
    "just" "gum" "ripgrep" "fd" "jq" "yq" "bat" "eza" "fzf"
    "nil" "nixfmt-rfc-style" "nh" "nix-output-monitor"
    "podman" "qemu"
    "d2" "graphviz" "plantuml"
    "f3d" "openscad"
    "typst" "zathura" "glow"
    "inkscape" "ffmpeg"
    "raylib" "entr" "lazygit" "gh" "tree" "opencode" "ollama" "nh"
    "ast-grep" "wiki-tui" "posting"
  ];
}
