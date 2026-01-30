# Agent Options - algorithm selection
{ lib, ... }:
{
  options.rl.agent = {
    algorithm = lib.mkOption { type = lib.types.enum [ "ppo" "a2c" "dqn" "sac" "td3" ]; default = "ppo"; };
    policyType = lib.mkOption { type = lib.types.enum [ "MlpPolicy" "CnnPolicy" "MultiInputPolicy" ]; default = "MlpPolicy"; };
    netArch = lib.mkOption { type = lib.types.listOf lib.types.int; default = [ 64 64 ]; };
  };
}
