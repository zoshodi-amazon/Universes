# AI

OpenCode AI coding agent via home-manager `programs.opencode` module.

## Structure

```
AI/
├── Types/
│   ├── NixOpencode/default.nix  # Options (enable, provider, region, profile, endpoint, rules, extraSettings)
│   └── default.nix
├── Monads/
│   ├── IOMNixOpencode/default.nix
│   └── default.nix
├── default.nix                  # → flake.modules.homeManager.ai
└── README.md
```

## Provider

Default: Amazon Bedrock with AWS profile auth. Supports VPC PrivateLink via `endpoint`.

## Usage

Override in Fleet instantiation:

```nix
ai.opencode = {
  enable = true;
  provider = "amazon-bedrock";
  region = "us-east-1";
  profile = "my-aws-profile";
  rules = [ "Always read AGENTS.md before changes" ];
};
```

## Invariant Check

```
Types/NixOpencode/  → Monads/IOMNixOpencode/   [OK]
```
