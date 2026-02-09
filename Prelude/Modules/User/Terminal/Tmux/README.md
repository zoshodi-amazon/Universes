# Tmux

Terminal multiplexer capability.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | User / Terminal |
| Purpose | Terminal multiplexing, session persistence |
| Targets | homeManager |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | true | Enable tmux |
| `prefix` | str | "C-a" | Prefix key |
| `baseIndex` | int | 1 | Start window numbering |
| `escapeTime` | int | 10 | Escape delay (ms) |
| `historyLimit` | int | 10000 | Scrollback lines |
| `mouse` | bool | true | Mouse support |
| `terminal` | str | "tmux-256color" | Terminal type |
| `extraConfig` | lines | "" | Additional tmux config |

## Keymaps

| Key | Action |
|-----|--------|
| `prefix + \|` | Split horizontal |
| `prefix + -` | Split vertical |
| `prefix + h/j/k/l` | Vim-like pane navigation |
| `Alt + arrows` | Pane nav (no prefix) |
| `prefix + H/J/K/L` | Resize pane |
| `prefix + r` | Reload config |
| `prefix + t` | Popup terminal |
| `prefix + g` | Popup lazygit |
| `prefix + f` | Popup fzf |
