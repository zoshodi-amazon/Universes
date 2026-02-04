{ pkgs, ... }:
{
  perSystem = { system, ... }: {
    packages.gym-anytrading = pkgs.python3Packages.buildPythonPackage rec {
      pname = "gym-anytrading";
      version = "2.0.0";
      
      src = pkgs.fetchFromGitHub {
        owner = "AminHP";
        repo = "gym-anytrading";
        rev = "v${version}";
        sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };
      
      propagatedBuildInputs = with pkgs.python3Packages; [
        gymnasium
        numpy
        pandas
        matplotlib
      ];
      
      doCheck = false;
      
      meta = {
        description = "OpenAI Gym trading environments for FOREX and Stocks";
        homepage = "https://github.com/AminHP/gym-anytrading";
        license = pkgs.lib.licenses.mit;
      };
    };
  };
}
