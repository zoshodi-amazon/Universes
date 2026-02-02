# Nixvim Module

## Structure

```
Nixvim/
├── Env/                    # ENV var aggregation
├── Instances/              # Wires config → programs.nixvim
└── Universe/
    ├── Core/               # Base vim options
    ├── Keymaps/            # Key bindings (ontological categories)
    └── Plugins/            # Plugin configs (directory = namespace)
        ├── Completion/     # → config.nixvim.plugins.completion
        ├── Git/            # → config.nixvim.plugins.git
        ├── Markdown/       # → config.nixvim.plugins.markdown
        ├── Navigation/     # → config.nixvim.plugins.navigation
        ├── Nix/            # → config.nixvim.plugins.nix
        └── Ui/             # → config.nixvim.plugins.ui
```

## Plugin Convention

**Directory name = config namespace**. The path `Universe/Plugins/<Category>/Bindings/default.nix` must set:

```nix
config.nixvim.plugins.<category> = lib.mkIf config.nixvim.enable {
  <plugin>.enable = true;
};
```

Example for `Universe/Plugins/Markdown/Bindings/default.nix`:

```nix
{ config, lib, ... }:
{
  config.nixvim.plugins.markdown = lib.mkIf config.nixvim.enable {
    glow.enable = true;
    markdown-preview = {
      enable = true;
      autoLoad = true;  # load immediately, not just for .md files
    };
  };
}
```

## Keymap Convention

Keymaps in `Universe/Keymaps/Bindings/default.nix` are organized ontologically:

| Prefix | Category | Examples |
|--------|----------|----------|
| `<leader>c` | Computation | code actions, format, build |
| `<leader>i` | Information | files, buffers, grep, harpoon |
| `<leader>s` | Signal | diagnostics, notifications |
| `<leader>m` | Meta | help, keymaps, preview |

## Flow

```
Universe/Plugins/*/Bindings/default.nix
    ↓ sets config.nixvim.plugins.<category>
Instances/default.nix
    ↓ merges all: plugins = lib.mkMerge (lib.attrValues cfg.plugins)
programs.nixvim.plugins
```
