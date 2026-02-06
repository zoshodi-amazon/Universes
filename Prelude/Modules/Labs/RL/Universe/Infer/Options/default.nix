# Infer Options - inference configuration
{ lib, ... }:
{
  options.rl.infer = {
    modelPath = lib.mkOption { type = lib.types.str; default = "./models/best_model.zip"; };
    device = lib.mkOption { type = lib.types.enum [ "auto" "cpu" "cuda" "mps" ]; default = "auto"; };
  };
}
