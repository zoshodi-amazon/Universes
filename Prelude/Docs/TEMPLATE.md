# MODULE TEMPLATE

Frozen structure for all modules. Source of truth for `just new-module`.

Pattern Version: v1.0.3 | Structure: FROZEN

## Directory Structure

```
<Module>/
├── README.md
├── default.nix
├── Env/
│   └── default.nix
├── Instances/
│   └── default.nix
└── Universe/
    └── <Feature>/
        ├── Options/
        │   └── default.nix
        └── Bindings/
            └── default.nix
```

## File Contents

### default.nix (Module root)

Empty tensor for import-tree entry point.

```nix
{ ... }: { }
```

### Env/default.nix

Aggregates Universe/*/Options into ENV vars.

```nix
{ config, lib, ... }:
let
  cfg = config.<module>;
in
{
  # ENV var aggregation from Options
}
```

### Instances/default.nix

Consumes Env, exports to flake targets.

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.<module>;
in
{
  # flake.modules.homeManager.<name> = ...
  # perSystem.packages.<name> = ...
  # perSystem.devShells.<name> = ...
}
```

### Universe/default.nix

Empty tensor.

```nix
{ ... }: { }
```

### Universe/<Feature>/default.nix

Empty tensor.

```nix
{ ... }: { }
```

### Universe/<Feature>/Options/default.nix

Capability schema. Vendor-agnostic types.

```nix
{ lib, ... }:
{
  options.<module>.<feature> = {
    enable = lib.mkEnableOption "<feature>";
    # Add capability options here (NOT tool-specific)
  };
}
```

### Universe/<Feature>/Bindings/default.nix

Implementation. Vendor-specific wiring.

```nix
{ config, lib, ... }:
let
  cfg = config.<module>.<feature>;
in
{
  config = lib.mkIf cfg.enable {
    # Wire Options to ENV vars, packages, etc.
  };
}
```

### Bindings/Scripts/default.nu

Interpreter script. Reads Options, executes effects. NO hidden CLI params.

```nu
#!/usr/bin/env nu

# Interpreter for <feature> - reads config, executes
def main [config_path: string] {
  let cfg = (open $config_path)
  # Interpret cfg into tool invocations
}
```

### README.md

```markdown
# <Module>

<One-line description of capability>

## Features

| Feature | Capability |
|---------|------------|
| <Feature> | <What it provides> |

## Options

See `just options Modules/<Category>/<Module>`

## Usage

<How to use the capability>
```

## Bindings Subdirectories

When a Feature needs structured bindings, use these subdirectories:

```
Bindings/
├── default.nix      # Main binding logic
├── Scripts/         # Entry points (default.nu)
├── Commands/        # CLI commands
├── Keymaps/         # Input bindings
├── Hooks/           # Lifecycle (Init, Save, Load, Log, Sync, Cleanup)
├── State/           # State machines
├── Secrets/         # Sensitive data
└── Plugins/         # Extensions
```

Each subdirectory contains `default.nix` or `default.nu` as appropriate.
