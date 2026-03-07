# HomeLab

**Artifact type**: home-manager configurations (user-level dotfiles, shell, editor, packages)

HomeLab produces typed `homeConfigurations` — the user-level complement to SystemLab's system-level `nixosConfigurations` and `darwinConfigurations`.

## 7-Phase IO Structure

| Phase | Artifact | Description |
|-------|----------|-------------|
| IOIdentityPhase | Git config, user identity | Who the user is across machines |
| IOCredentialsPhase | SSH keys, tokens | How the user authenticates |
| IOShellPhase | zsh, fish, nushell, direnv | Interactive shell environment |
| IOTerminalPhase | tmux, kitty | Terminal emulator + multiplexer |
| IOEditorPhase | nixvim, AI assistant | Editor configuration |
| IOCommsPhase | mail, browser | Communication tools |
| IOPackagesPhase | core packages, cloud CLI | User-level package set |

## Type Hierarchy

```
Types/
├── Identity/     — terminal objects (Package, ProgramConfig)
├── Inductive/    — ADTs (ShellEditor, TmuxPrefix, KittyTheme, ...)
├── Dependent/    — parameterized configs (GitConfig, AIConfig, ...)
├── Hom/          — phase input morphisms (7 phases)
├── Product/      — phase outputs (7 x Meta + Output)
├── Monad/        — effect types
└── IO/           — 7 phase executors (default.json + default.nix)

CoTypes/          — dual observation types (1:1 with Types/)
```

## Invariants

- One type per file (`<TypeName>/Default.lean`)
- IO/ capped at exactly 7 subdirectories
- `local.json` for site-specific overrides (never committed)
- Lean types are the source of truth; JSON is the boundary; Nix is the IO executor
