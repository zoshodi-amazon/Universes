# UNIVERSES(7) - Dendritic Nix Configuration System

## NAME

Universes - Dendritic Nix configuration system using flake-parts + import-tree

## SYNOPSIS

```
Modules/
├── Computation/    # Process: interpreters, editors, services
├── Information/    # Symbol: code, docs, databases
├── Labs/           # Workstation: audio, video, signal processing
└── Physical/       # Matter: hardware, materials
```

**Pattern Version: v1.0.3** | **Structure: FROZEN**

## DESCRIPTION

Capability-centric, vendor-agnostic configuration system built on two adjoint pairs:

**Global Duality** (Module-level): `Env ⊣ Instances`
- Env aggregates Options → ENV vars (left adjoint, free)
- Instances consumes Env → Nix targets (right adjoint, forgetful)

**Local Duality** (Universe-level): `Options ⊣ Bindings`
- Options: schema, types, constraints (interface)
- Bindings: runtime behavior, effects (implementation)

## OPTIONS

Options must remain vendor-agnostic ("what I want"), Bindings are vendor-specific ("how to get it").

**Anti-pattern** (coupled):
```nix
options.store.mlflow.trackingUri = ...;  # ❌ Vendor in Options
```

**Correct pattern** (decoupled):
```nix
options.store.trackingUri = ...;         # ✓ Generic
options.store.backend = enum [ "mlflow" "wandb" "local" ];
```

Decision tree:
```
Is this field specific to ONE vendor?
  YES → Handle in Bindings, not Options
  NO → Is it a universal capability? → Add to Options with generic name
```

## FILES

Every module follows this frozen structure:

```
<Module>/
├── README.md           # Documentation (man format)
├── default.nix         # Tensor (empty, import-tree entry)
├── Env/                # ENV var aggregation
├── Instances/          # flake.modules.* exports
├── Drv/                # Optional: custom derivations
└── Universe/
    └── <Feature>/
        ├── Options/    # Schema
        └── Bindings/   # Effects (Scripts, Commands, Keymaps, Hooks, State, Secrets, Plugins)
```

## ENVIRONMENT

Flake targets:

| Target | Scope | Purpose |
|--------|-------|---------|
| `flake.modules.homeManager.*` | User | Home-manager modules |
| `flake.modules.nixos.*` | System | NixOS modules |
| `flake.modules.darwin.*` | System | nix-darwin modules |
| `perSystem.devShells.*` | Dev | Development environments |
| `perSystem.packages.*` | Build | Derivations |
| `perSystem.checks.*` | CI | Validation |

Bindings categories:

| Category | Signature | Purpose |
|----------|-----------|---------|
| Scripts | `() → Effect` | Entry points (default.nu) |
| Commands | `Cmd → Effect` | CLI commands |
| Keymaps | `Key → Action` | Input bindings |
| Hooks | `Event → Effect` | Lifecycle |
| State | `S → S` | State machines |
| Secrets | `Path → Value` | Sensitive data |
| Plugins | `Base → Extended` | Extensions |

## EXAMPLES

Module wrapping philosophy - no shells, only CLI:

```nix
# Universe/Core/Options/default.nix
options.coolTool = {
  enable = lib.mkEnableOption "cool-tool";
  port = lib.mkOption { type = lib.types.port; default = 8080; };
  logLevel = lib.mkOption { type = lib.types.enum ["debug" "info" "warn"]; default = "info"; };
};

# Instances/default.nix
config.perSystem = { pkgs, ... }: lib.mkIf cfg.enable {
  packages.cool-tool = pkgs.writeShellScriptBin "cool-tool" ''
    export COOL_TOOL_PORT="${toString cfg.port}"
    export COOL_TOOL_LOG_LEVEL="${cfg.logLevel}"
    exec ${pkgs.cool-tool}/bin/cool-tool "$@"
  '';
};
```

Users interact via: `cool-tool --some-flag` (globally available, no shell needed).

Introspect options to prevent type mismatches:

```bash
introspect-options Modules/Computation/Services/RL
# Shows all Universe/*/Options for the module
```
options.coolTool = {
  enable = lib.mkEnableOption "cool-tool";
  port = lib.mkOption { type = lib.types.port; default = 8080; };
};

# Instances/default.nix
config.perSystem = { pkgs, ... }: lib.mkIf cfg.enable {
  devShells.cool-tool = pkgs.mkShell {
    packages = [ pkgs.cool-tool ];
    shellHook = ''export COOL_TOOL_PORT="${toString cfg.port}"'';
  };
};
```

Configuration surface isomorphism:
```
CLI flags ≅ ENV vars ≅ Config files ≅ Options/default.nix
```

## DIAGNOSTICS

Category decision tree:
```
Is it a transformation/process? → Computation/
Is it structured, discrete, stored? → Information/
Is it continuous transmission? → Signal/
Is it tangible hardware? → Physical/
```

Quick reference:

| Thing | Category | Why |
|-------|----------|-----|
| Neovim, shells | Computation | Transforms text |
| Git repo, configs | Information | Stores symbols |
| OTEL, Prometheus | Signal | Telemetry streams |
| GPU, sensors | Physical | Hardware |

## CAVEATS

1. Every `.nix` file is a flake-parts module
2. Every Module has: README.md, default.nix, Env/, Instances/, Universe/
3. Every Universe/Feature has: Options/, Bindings/
4. NO manual imports (import-tree auto-imports)
5. File naming: `default.*` only
6. Standard scripting: Nushell (`default.nu`)
7. Modules enable themselves: if created, capability is desired
8. Binding locality: submodule bindings stay in subdir, global in Instances/
9. **NO SHELLS**: Wrap everything as CLI commands, interact via ENV vars only
10. Use `introspect-options <module>` to prevent type mismatches

Common pitfalls:

| Issue | Solution |
|-------|----------|
| Nix float literals fail | Use `lib.types.str`, parse in binding |
| Infinite recursion | Don't set `x.enable` inside `mkIf x.enable` |
| Module not exported | Ensure `enable = true` in Bindings |
| New dirs not found | `git add` before rebuild (import-tree) |
| Shell headaches | Don't use shells - CLI commands only |
| Type mismatches | Use `introspect-options <module-path>` |

## USAGE

```bash
nix flake check                           # Check invariants
nix build .#homeConfigurations.darwin.activationPackage
home-manager switch --flake .#darwin      # Switch config
nix develop .#checks                      # Enter dev shell
```

## SEE ALSO

- `Prelude/Modules/Computation/Editor/Nixvim/README.md`
- `Prelude/Modules/Computation/Editor/Nixvim/architecture.d2`

## HISTORY

| Version | Date | Changes |
|---------|------|---------|
| v1.0.3 | 2026-01-27 | README.md required, Nushell standard |
| v1.0.2 | 2026-01-27 | Plugins in Bindings/, 7 binding types |
| v1.0.1 | 2026-01-27 | default.nix naming |
| v1.0.0 | 2026-01-27 | Frozen structure, two-level adjunction |

## AUTHORS

Dendritic Nix pattern v1.0.3
