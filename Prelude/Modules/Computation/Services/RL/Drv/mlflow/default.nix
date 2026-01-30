# MLflow derivation
{ lib, ... }:
{
  config.perSystem = { pkgs, ... }:
  let
    python = pkgs.python311;
  in {
    packages.mlflow = python.pkgs.buildPythonPackage rec {
      pname = "mlflow";
      version = "2.10.0";
      format = "pyproject";
      src = pkgs.fetchFromGitHub {
        owner = "mlflow";
        repo = "mlflow";
        rev = "v${version}";
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };
      nativeBuildInputs = with python.pkgs; [ setuptools ];
      propagatedBuildInputs = with python.pkgs; [
        click flask gunicorn numpy pandas protobuf pyyaml requests sqlalchemy
      ];
      doCheck = false;
    };
  };
}
