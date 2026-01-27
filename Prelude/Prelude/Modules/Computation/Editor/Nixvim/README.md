# Nixvim Module

## Canonical Module Structure (6 dirs)

Required:
- **Options/** source of truth (schema)
- **Env/** 1-1 env var mapping
- **Bindings/** runtime imperative (keymaps, scripts, commands)
- **Plugins/** plugin/extension configs
- **Instances/** class targets (nixos, darwin, homeManager, devShells)

Optional:
- **Drv/** custom derivation (when wrapping a package not in nixpkgs)

```
<Module>/
├── Options/index.nix
├── Env/index.nix
├── Bindings/
│   ├── Keymaps/index.nix
│   ├── Scripts/index.nix
│   ├── Commands/index.nix
│   └── index.nix
├── Plugins/index.nix
├── Instances/index.nix
├── Drv/index.nix          # optional
└── index.nix
```

## The Isomorphism

```
Options ≅ Env ≅ Bindings
   ↓       ↓       ↓
Schema → Vars → Keymaps/Scripts/Commands
```
