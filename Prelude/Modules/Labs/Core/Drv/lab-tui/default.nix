{ pkgs, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.lab-tui = pkgs.buildGoModule {
      pname = "lab-tui";
      version = "0.1.0";
      src = ./.;
      vendorHash = null;
      meta = {
        description = "Generic Lab TUI framework";
        mainProgram = "lab-tui";
      };
    };
  };
}
