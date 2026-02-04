# Scripts

Nushell scripts for module introspection, scaffolding, and deployment.

## Features

| Feature | Capability |
|---------|------------|
| Discover | List modules in the system |
| Introspect | Show features and options for modules |
| Scaffold | Create new modules and features |
| Deploy | Flash ISOs, format persistence, remote builds |

## Options

See `just options Modules/Computation/Scripts`

## Usage

All scripts are invoked through the justfile:

```bash
just modules                    # Discover
just features <module>          # Introspect
just options <module>           # Introspect
just new-module <path>          # Scaffold
just new-feature <module> <name> # Scaffold
just flash <machine> <disk>     # Deploy
```
