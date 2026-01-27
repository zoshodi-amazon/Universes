# MonadEnvIO: Audio shell aggregator
{ self }:
{
  imports = [
    "${self}/Types/Context/EnvIO/Outputs/index.nix"
    "${self}/Types/Transform/FormatterIO/Outputs/index.nix"
    "${self}/Types/Transform/ChecksIO/Outputs/index.nix"
    "${self}/Types/Transform/InterpretersIO/Outputs/index.nix"
    "${self}/Types/Transform/RenderersIO/Outputs/index.nix"
  ];
}
