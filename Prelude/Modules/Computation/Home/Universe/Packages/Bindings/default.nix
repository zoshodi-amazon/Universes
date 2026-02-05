# Core packages bindings
{ ... }:
{
  config.home.corePackages = [
    # Core CLI
    "just"
    "gum"
    "ripgrep"
    "fd"
    "jq"
    "yq"
    "bat"
    "eza"
    "fzf"
    # Nix
    "nil"
    "nixfmt-rfc-style"
    # Diagrams
    "d2"
    "graphviz"
    "plantuml"
    # CAD/3D
    "f3d"
    "openscad"
    # "blender"  # broken in nixpkgs currently
    # Docs
    "typst"
    "zathura"
    "glow"
    # Media
    "mpv"
    "inkscape"
    "ffmpeg"
    # Game/Graphics
    "raylib"
    # Labs
    "entr"
  ];
}
