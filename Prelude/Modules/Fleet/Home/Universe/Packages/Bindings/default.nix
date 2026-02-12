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
    "nh"
    "nix-output-monitor"
    # Containers
    "podman"
    # Virtualization
    "qemu"
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
    # "mpv"  # pulls in Swift compiler on darwin — disabled until cached
    "inkscape"
    "ffmpeg"
    # Game/Graphics
    "raylib"
    # Labs
    "entr"
    #Git
    "lazygit"
    "gh"
    #Tree
    "tree"
    # AI
    "opencode"
    "ollama"
    # Nix
    "nh"
  ];
}
