# Service (FSC Abstract)

## FSC Definition

A Service is a category in FSC characterized by its three canonical sum types representing long-running background processes.

### Types/Services/
Type definitions for daemon/service configurations:
- Service specifications (ExecStart, dependencies)
- Resource limits (memory, CPU, file descriptors)
- Restart policies (on-failure, always)
- Environment configuration (env vars, working directory)
- Logging configuration (stdout, stderr, syslog)

Optional Pure/Effects separation:
- Pure/ - Static service definitions
- Effects/ - Service lifecycle (start, stop, restart, reload)

### Monads/Services/
Type constructors that produce service artifacts:
- MonadFlake - Produces flake with service definitions
- MonadSystemd - Produces systemd unit files
- MonadLaunchd - Produces launchd plist files

Each Monad: Types/Services/ -> Artifacts/Services/<Target>/

### Artifacts/Services/
Type inhabitants - the actual service outputs:
- Flake/flake.nix - Canonical service flake
- Systemd/ - systemd unit files (.service, .socket, .timer)
- Launchd/ - launchd plist files

## Categorical Properties

1. Hard boundary - Services/ cannot import from other categories
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - Service category maps to itself through Monads
4. Composable - Services typically deployed via Systems/ category

## Type-Theoretic Structure

```
Service :: Category
  where
    Types     :: Pure ⊕ Effects
    Monads    :: Type -> Artifact
    Artifacts :: Value
```

Service as unit:
```
Service :: ServiceConfig
Service = {
  description : String
  after       : [Service]
  requires    : [Service]
  execStart   : Path
  restart     : RestartPolicy
  environment : AttrSet String
}
```

## Flow

```
Types/Services/Pure/Spaces/       # Service option definitions
Types/Services/Pure/Bindings/     # Concrete service configs
         ↓
Monads/Services/MonadSystemd/     # Construct systemd units
         ↓
Artifacts/Services/Systemd/       # Built .service files
```

## Integration

Services typically integrated via Systems/:
```
Types/Systems/ imports Types/Services/
Monads/Systems/ composes Services into system config
Artifacts/Systems/ includes service activation
```

---

Last Updated: 2026-01-15
