# Feature Options - feature engineering
{ lib, ... }:
{
  options.rl.feature = {
    encoder = lib.mkOption { type = lib.types.enum [ "mlp" "cnn" "transformer" ]; default = "mlp"; };
    embedDim = lib.mkOption { type = lib.types.int; default = 64; };
  };
}
