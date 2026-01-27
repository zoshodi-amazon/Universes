# Tmux Module

Terminal multiplexer configuration.

## Structure

```
Tmux/
├── Options/index.nix           # prefix, baseIndex, mouse, etc
├── Env/index.nix               # TMUX_* vars
├── Bindings/
│   ├── Keymaps/index.nix       # key bindings
│   └── index.nix
├── Plugins/index.nix           # sensible, yank, resurrect, continuum
├── Instances/index.nix         # homeManager target
└── index.nix
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| prefix | C-a | Prefix key |
| baseIndex | 1 | Start window numbering |
| escapeTime | 10 | Escape delay (ms) |
| historyLimit | 10000 | Scrollback lines |
| mouse | true | Mouse support |
| terminal | tmux-256color | Terminal type |

## Keymaps

| Key | Action |
|-----|--------|
| prefix + \| | Split horizontal |
| prefix + - | Split vertical |
| prefix + hjkl | Vim-like pane nav |
| Alt + arrows | Pane nav (no prefix) |
| prefix + r | Reload config |
| prefix + t | Popup terminal |
| prefix + g | Popup lazygit |
| prefix + f | Popup fzf file picker |

## Usage

```nix
{
  tmux.enable = true;
  tmux.prefix = "C-a";
  tmux.mouse = true;
}
```
