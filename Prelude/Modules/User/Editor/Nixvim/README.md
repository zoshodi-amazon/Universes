# NIXVIM(7) - Neovim Configuration Module

## NAME

Nixvim - Neovim configuration via nixvim, organized by filetype → renderer pairing

## SYNOPSIS

```
Modules/User/Editor/Nixvim/
├── Env/
├── Instances/
└── Universe/Plugins/{Documentation,Languages,Data,Media,Web,...}/
```

## DESCRIPTION

Nixvim module following the dendritic nix pattern. Each plugin category maps filetypes to renderers/previewers, with keymaps co-located alongside plugin bindings.

## OPTIONS

Base options defined in `Universe/Core/Options/default.nix`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `nixvim.enable` | bool | false | Enable nixvim |
| `nixvim.colorscheme` | str | "tokyonight" | Color scheme |
| `nixvim.leader` | str | " " | Leader key |
| `nixvim.tabWidth` | int | 2 | Tab width |

## FILES

```
Universe/
├── Core/               # Base vim options
├── Keymaps/            # Core/builtin keymaps only
└── Plugins/
    ├── Completion/     # Autocomplete
    ├── Data/           # .json .yaml .csv .toml
    ├── Documentation/  # .md .d2 .tex
    ├── Git/            # Version control
    ├── Languages/      # .nix .lean .py .rs .ts
    ├── Media/          # .png .jpg .wav .mp4
    ├── Navigation/     # Telescope, Oil, Harpoon
    ├── Nix/            # Nix-specific
    ├── Ui/             # lualine, which-key
    └── Web/            # .html .css .jsx
```

## EXAMPLES

Plugin binding pattern:

```nix
# Universe/Plugins/<Category>/Bindings/default.nix
{ config, lib, ... }:
{
  config.nixvim.plugins.<category> = lib.mkIf config.nixvim.enable {
    <plugin>.enable = true;
  };

  config.nixvim.keymaps.<category> = lib.mkIf config.nixvim.enable [
    { mode = "n"; key = "..."; action = "..."; options.desc = "..."; }
  ];
}
```

External plugin (not in nixvim):

```nix
config.nixvim.extraPluginConfigs.<name> = lib.mkIf config.nixvim.enable {
  owner = "..."; repo = "..."; rev = "..."; sha256 = "...";
  config = "let g:... = 1";
};
```

## ENVIRONMENT

Keymaps organized by ontological category:

| Prefix | Category | Description |
|--------|----------|-------------|
| `<leader>c` | Computation | LSP, format, build |
| `<leader>i` | Information | Files, buffers, grep |
| `<leader>s` | Signal | Diagnostics, logs |
| `<leader>m` | Meta | Help, preview, docs |
| `<leader>d` | Data | jq/yq format |
| `<leader>l` | Languages | REPL, infoview |
| `<leader>w` | Web | Live server |

## DIAGNOSTICS

Filetype-specific commands only available in matching buffers:

| Plugin | Filetype | Commands |
|--------|----------|----------|
| d2-vim | `.d2` | `:D2PreviewToggle` `:D2Fmt` |
| glow | `.md` | `:Glow` |
| lean.nvim | `.lean` | `:LeanInfoviewToggle` |

## CAVEATS

- Plugin keymaps MUST live with plugin Bindings (binding locality invariant)
- External plugins require sha256 hash from `nix-prefetch-url --unpack`
- New plugin dirs must be `git add`ed before rebuild (import-tree)

## SEE ALSO

- `architecture.d2` - Visual diagram (`<leader>md` to preview)
- `~/repos/Universes/README.md` - Pattern documentation

## AUTHORS

Dendritic Nix pattern v1.0.3
