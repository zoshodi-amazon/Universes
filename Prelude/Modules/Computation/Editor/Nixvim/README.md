# Nixvim Module

## Structure

```
Nixvim/
├── Env/                    # ENV var aggregation
├── Instances/              # Global bindings → programs.nixvim
└── Universe/
    ├── Core/               # Base vim options
    ├── Keymaps/            # ONLY core/builtin keymaps
    └── Plugins/            # Plugin configs + local keymaps
        ├── Completion/     # → config.nixvim.plugins.completion
        ├── Documentation/  # → config.nixvim.plugins.documentation
        ├── Git/            # → config.nixvim.plugins.git
        ├── Navigation/     # → config.nixvim.plugins.navigation
        ├── Nix/            # → config.nixvim.plugins.nix
        └── Ui/             # → config.nixvim.plugins.ui
```

## Binding Locality Invariant

**CRITICAL**: Bindings are scoped to their subdir level.

| Scope | Location | Purpose |
|-------|----------|---------|
| Global | `Instances/` | Wires to flake-parts targets (programs.nixvim) |
| Submodule | `Universe/<Feature>/Bindings/` | Feature-specific config + keymaps |

**Why**: If a plugin isn't loaded, its keymaps shouldn't exist. Co-locating ensures the Options ⊣ Bindings contract holds.

## Plugin Convention

**Directory name = config namespace**:

```nix
# Universe/Plugins/<Category>/Bindings/default.nix
{ config, lib, ... }:
{
  # Plugin config
  config.nixvim.plugins.<category> = lib.mkIf config.nixvim.enable {
    <plugin>.enable = true;
  };

  # Keymaps co-located - guaranteed to exist when plugin loads
  config.nixvim.keymaps.<category> = lib.mkIf config.nixvim.enable [
    { mode = "n"; key = "<leader>xx"; action = "<cmd>PluginCommand<cr>"; options.desc = "..."; }
  ];
}
```

## Filetype-Specific Commands

Some plugins (like d2-vim) register commands only for specific filetypes:

| Plugin | Filetype | Commands |
|--------|----------|----------|
| d2-vim | `.d2` | `:D2PreviewToggle`, `:D2Fmt`, `:D2Validate` |
| glow | `.md` | `:Glow` |
| markdown-preview | `.md` | `:MarkdownPreview` |

Visual mode keymaps (e.g., `<leader>md` → `D2PreviewSelection`) work in any file for selected text.

## Keymap Ontology

| Prefix | Category | Examples |
|--------|----------|----------|
| `<leader>c` | Computation | code actions, format, build |
| `<leader>i` | Information | files, buffers, grep, harpoon |
| `<leader>s` | Signal | diagnostics, notifications |
| `<leader>m` | Meta | help, keymaps, preview, docs |

## Central Keymaps (Universe/Keymaps/)

ONLY contains always-available bindings:
- Core vim motions
- LSP keymaps (`vim.lsp.buf.*`)
- Diagnostics (`vim.diagnostic.*`)

## Flow

```
Universe/Plugins/*/Bindings/
    ↓ sets config.nixvim.plugins.<category>
    ↓ sets config.nixvim.keymaps.<category>  ← co-located!
Instances/
    ↓ merges: plugins = lib.mkMerge (lib.attrValues cfg.plugins)
    ↓ merges: keymaps = lib.flatten (lib.attrValues cfg.keymaps)
programs.nixvim
```
