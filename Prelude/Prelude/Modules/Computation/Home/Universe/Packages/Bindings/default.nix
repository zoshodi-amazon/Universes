# Core packages bindings
{ ... }:
{
  config.home.corePackages = [
    "just"
    "ripgrep"
    "fd"
    "jq"
    "bat"
    "eza"
    "fzf"
    "nil"
    "nixfmt-rfc-style"
  ];
}
