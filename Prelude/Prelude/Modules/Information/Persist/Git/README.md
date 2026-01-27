# Git

Persistent version control configuration.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Information / Persist |
| Purpose | Git identity and workflow configuration |
| Targets | homeManager |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/Config/Options | Exports `flake.modules.homeManager.git` |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Config | user.name, user.email, editor, defaultBranch | — |

## Options

| Option | Type | Default |
|--------|------|---------|
| `git.enable` | bool | true |
| `git.userName` | string | — |
| `git.userEmail` | string | — |
| `git.editor` | string | "nvim" |
| `git.defaultBranch` | string | "main" |
