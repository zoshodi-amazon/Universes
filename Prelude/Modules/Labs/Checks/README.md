# Checks Module

Pre-commit hooks and linting for multiple languages.

## Structure

```
Checks/
├── Options/index.nix    # Language toggles
├── Env/index.nix        # CHECKS_* vars
├── Bindings/index.nix   # Pre-commit hook script
├── Instances/index.nix  # devShells, checks targets
└── index.nix
```

## Supported Languages

| Language | Tools |
|----------|-------|
| nix | nixfmt, deadnix, statix |
| python | ruff, mypy, black |
| java | checkstyle, google-java-format |
| typescript | tsc, eslint |
| javascript | eslint, prettier |
| vue | eslint, prettier |
| rust | clippy, rustfmt |
| go | golangci-lint, gofumpt |
| shell | shellcheck, shfmt |

## Usage

```nix
{
  checks.enable = true;
  checks.preCommit.enable = true;
  checks.nix.enable = true;
  checks.python.enable = true;
}
```

## Env Vars

```
CHECKS_PRE_COMMIT=true
CHECKS_NIX=true
CHECKS_PYTHON=true
...
```
