# <Term> (FSC Abstract)

## FSC Definition

A <Term> is a category in FSC characterized by its three canonical sum types:

### Types/<Category>/
Type definitions for <brief description>:

Inputs/ - Grounded types (owned by this category):
- <Type1>/ - <Description>
  - Spaces/ + Bindings/ (grounded <language type>)
- <Type2>/ - <Description>
  - Spaces/ + Bindings/ (grounded <language type>)

Outputs/ - Dependent types (external dependencies):
- <Type3>/ - <Description>
  - Spaces/ only (NO Bindings/ - free parameter)
- <Type4>/ - <Description>
  - Spaces/ only (NO Bindings/ - external dependency)

### Monads/<Category>/
Type constructors that produce <term> artifacts:
- MonadFlake - Identity type (mandatory)
- Monad<Target1> - Produces <target1 description>
  - Depends on Monad<External> (if applicable)
- Monad<Target2> - Produces <target2 description>

Each Monad: Types/<Category>/ -> Artifacts/<Category>/<Target>/

Dependencies:
- Types/<Category>/Pure/<Type>/ (grounded internally)
- Monads/<External>/Monad<External>/ (external dependencies)

### Artifacts/<Category>/
Type inhabitants - the actual <term> outputs:
- Flake/flake.nix - Canonical <term> flake (outputs.<outputType>)
- <Target1>/ - <Target1 output description>
- <Target2>/ - <Target2 output description>

## Categorical Properties

1. Hard boundary - <Category>/ cannot import from other categories
2. Traced monoidal - Types -> Monads -> Artifacts forms closed loop
3. Endofunctor - <Category> category maps to itself through Monads
4. Composable - <How this category composes with others>

## Type-Theoretic Structure

```
<Term> :: Category
  where
    Types     :: Pure ⊕ Effects
    Monads    :: Type -> Artifact
    Artifacts :: Value
```

<Optional: Additional type signatures specific to this category>

## Flow

```
Types/<Category>/Pure/<Type>/Bindings/       # Grounded type
Types/<Category>/Effects/<Type>/Spaces/      # Dependent type (NO Bindings/)
         ↓
Monads/<Category>/Monad<Target>/             # Grounds dependencies
         ↓
Artifacts/<Category>/<Target>/               # Fully grounded artifact
```

## Core Identity Categories

**Flake** - Universal identity
- Every category must have MonadFlake
- Produces canonical flake output

**Packages** - Fundamental units
- Every category depends on Packages
- Every category must have MonadPackages
- Grounds package dependencies

**Modules** - Configuration/customization
- Every category depends on Modules
- Every category must have MonadModules
- Encapsulates all configuration and customization
- Configuration = Binding at the Module level

**Systems** - Deployment targets
- Every category depends on Systems
- Every category must have MonadSystems
- Defines where artifacts are deployed

## Naming Convention

**<Category>Module** - The categorical type space (Level 2)
**<Category>Config** - A configuration binding within that Module
**<Category>Package** - Package-level category (Level 1)
**<Category>System** - System-level artifact (Level 0)

Examples:
- UserModule (category) → UserConfig (binding)
- EditorModule (category) → EditorConfig (binding)
- ScriptsPackage (category) → ScriptsTasks (binding)

## Universal Monad Signature

Every non-core category has this signature:
```
Monad<Target> :: Monad<Packages, Modules, Systems, Flake>
```

Core categories (Packages, Modules, Systems) only depend on Flake:
```
MonadPackages :: Monad<Flake>
MonadModules  :: Monad<Flake>
MonadSystems  :: Monad<Flake>
```

## Monad Naming Convention

Monads explicitly list their dependencies in type signature:

```
Monad<Target> :: Monad<Dep1, Dep2, ..., Flake>
```

Examples:
```
MonadShell  :: Monad<Packages, Scripts, Flake>
MonadHome   :: Monad<Packages, Modules, Flake>
MonadSystem :: Monad<Packages, Modules, Services, Flake>
```

Flake is always the last dependency (identity type).

## Pure vs Effects Invariant

Pure/ types:
- Have Spaces/ + Bindings/ (grounded within category)
- Example: <Type owned by this category>

Effects/ types:
- Have Spaces/ only (NO Bindings/ - free parameters)
- Example: <Type from external category>
- Grounded by external Monad (Monad<External>)

**Invariant**: Effects/<Type>/Bindings/ CANNOT exist (contradiction)

## Mechanical Validation (Sanity Check)

**Effects/ = Dependent Type Identities**

Every type in `Types/<Category>/Effects/` must have a corresponding Monad:

```
Types/<Category>/Effects/
├── EditorModule/         # Dependent type
├── TerminalModule/       # Dependent type
└── PackageConfig/        # Dependent type

Monads/<Category>/
├── MonadEditor/          # ✓ Grounds EditorModule
├── MonadTerminal/        # ✓ Grounds TerminalModule
└── MonadPackages/        # ✓ Grounds PackageConfig
```

**Validation Rule**: For every `Types/<Category>/Effects/<Type>/`, there must exist `Monads/<External>/Monad<Type>/`

If there's a type in Effects/ without a corresponding Monad, you have a **hole** (ungrounded free parameter).

This makes FSC mechanically verifiable - you can automatically check if a category is well-formed.

---

Last Updated: YYYY-MM-DD
