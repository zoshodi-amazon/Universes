# MonadFlakeIO: Audio-specific compositor
{ self }:
{
  imports = [
    "${self}/Types/Context/FlakeIO/Outputs/index.nix"
    (import "${self}/Monads/GlobalIO/Context/MonadEnvIO/index.nix" { inherit self; })
  ];
}
