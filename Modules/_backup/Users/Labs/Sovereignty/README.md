# Sovereignty

Off-grid, surveillance-resistant autonomous living capability space.

**Threat Model**: Complete surveillance society, satellite tracking, dual-mode (evasion + gray man)

## Structure

```
Sovereignty/
├── Types/           # Typed option modules (the type space)
│   └── Sovereignty/     # The ADT — complete ontology
│       └── default.lean # Canonical type definitions
│   └── default.nix      # Nix projection of the ADT
├── Monads/              # Artifact-producing scripts/derivations
│   └── MSovereignty/    # Pure queries (status, gaps, bom, weight, cost, signature, bootstrap)
│   └── IOMSovereignty/  # Effectful commands (validate, pack, discover, training)
│   └── IOMLeanPackage/  # Builds the sov CLI binary (lean4-nix)
├── default.nix          # Global instantiation (wires Types + Monads into flake)
└── README.md
```

## Naming Convention

```
Types/   → [IO?]{ArtifactType}     — typed option modules
Monads/      → [IO?]M{ArtifactType}    — artifact-producing scripts/derivations

IO prefix    = effectful (writes, deploys, interactive, modifies state)
no prefix    = pure (queries, observations, read-only)
M prefix     = Monad (type constructor that produces the artifact)
```

Every Artifact has a 1-1 Monad. Missing Monad = a hole.

| Artifact | Monad | IO? | Purpose |
|----------|-------|-----|---------|
| `Sovereignty` | `MSovereignty` | pure | Query the capability space (status, gaps, bom) |
| `Sovereignty` | `IOMSovereignty` | effectful | Modify state (validate, pack, discover) |
| `LeanPackage` | `IOMLeanPackage` | effectful | Build the sov CLI binary |

## Ontology

The entire system is defined by a single recursive ADT in `Types/Sovereignty/default.lean`.

```
Types/Sovereignty/default.lean (ADT)  ->  Types/default.nix (Nix projection)  ->  ENV vars (JSON)  ->  sov binary (Lean folds)  ->  IO effects
     types                                         type space                              serialized config      eliminators                  state
```

### Type Hierarchy

```
Sovereignty
  -- Global
  mode        : Mode (nomadic | urban | base)
  bootstrap   : Bootstrap (knowledge | energy | compute)
  opsec       : Opsec (7 layers: physical, signal, digital, social, financial, temporal, legal)
  constraints : ModeConstraints (nomadic: weight/volume, urban: blend, base: permanence)
  -- Tier 1 (spans all modes)
  energy       : Energy (generation, storage, distribution, signature)
  water        : Water (sources, purification, capacity, signature)
  food         : Food (acquisition, preservation, cultivation, signature)
  shelter      : Shelter (type, mobility, climate, signature)
  -- Tier 2 (required all modes, complexity varies)
  medical      : Medical (level, pharmacy, diagnostics, telemedicine)
  comms        : Comms (mesh, burst, encryption, rf, offline, signature)
  compute      : Compute (architecture, openness, airgap, knowledge)
  -- Tier 3 (mode-dependent intensity)
  intelligence : Intelligence (osint, sigint, counterSurveillance, re)
  defense      : Defense (perimeter, earlyWarning, physical, commsec)
  -- Tier 4 (most mode-specific)
  transport    : Transport (modes, fuel, navigation, signature)
  trade        : Trade (methods, crypto, supplyChain, signature)
  fabrication  : Fabrication (tier, capabilities, materials)
```

Every leaf capability contains `items : List Item` where:

```
Item
  name, model, qty, unitCost : Cost, weight : Mass, volume : Vol,
  packTime : Duration, source : SourceType, status : AcqStatus,
  competency : Competency, signature : Signature
```

No loose strings. Physical quantities are typed (value + unit). Sources are sum types. Status is a lifecycle enum.

### Globality Ordering

| Tier | Domains | Rationale |
|------|---------|-----------|
| 1 (most global) | Energy, Water, Food, Shelter | Required in ALL modes |
| 2 | Medical, Comms, Compute | Required in all modes, complexity varies |
| 3 | Intelligence, Defense | Mode-dependent intensity |
| 4 | Transport, Trade, Fabrication | Most mode-specific |

## Commands as Monads

Every command is an artifact-producing Monad. The naming tells you what it produces and whether it's effectful:

### MSovereignty (pure queries — read the type space)

| Command | Fold | Output |
|---------|------|--------|
| `sov status` | Coverage matrix | Per-domain acquired/total counts |
| `sov gaps` | Filter empty capabilities | List of (DomainId, CapId) |
| `sov bom` | Collect all items | Flat BOM with totals |
| `sov cost` | Sum unitCost * qty | Cost breakdown by domain |
| `sov weight` | Sum weight * qty | Weight breakdown by domain |
| `sov signature` | Aggregate signatures | OPSEC posture table |
| `sov bootstrap` | Gaps sorted by tier | Acquisition priority path |

### IOMSovereignty (effectful — modify state or interact)

| Command | Effect | Output |
|---------|--------|--------|
| `sov validate` | Check constraints | List of typed SovError |
| `sov pack <mode>` | Filter by mode constraints | Pack list + constraint violations |
| `sov discover <domain>` | Research tools | Gap analysis for domain |
| `sov training` | Filter untrained items | Training plan |

### IOMLeanPackage (effectful — build)

| Command | Effect | Output |
|---------|--------|--------|
| `lake build` | Compile Lean to native binary | `sov` executable |

## Errors

All errors are typed via `SovError` ADT:

```
SovError
  | missingItems (domain, cap)
  | overWeight (actual : Mass, limit : Mass)
  | overVolume (actual : Vol, limit : Vol)
  | overPackTime (actual : Duration, limit : Duration)
  | untrainedCapability (domain, cap, level)
  | noBootstrapPath (seed, missing)
  | signatureExposure (domain, sig)
```

## Justfile

The justfile aggregates all Monads as recipes:

```bash
just sov-status          # MSovereignty: coverage matrix
just sov-gaps            # MSovereignty: uncovered capabilities
just sov-bom             # MSovereignty: bill of materials
just sov-cost            # MSovereignty: cost breakdown
just sov-weight          # MSovereignty: weight breakdown
just sov-signature       # MSovereignty: OPSEC posture
just sov-bootstrap       # MSovereignty: acquisition priority
just sov-validate        # IOMSovereignty: check constraints
just sov-pack nomadic    # IOMSovereignty: filter by mode
just sov-discover energy # IOMSovereignty: research tools
just sov-training        # IOMSovereignty: training plan
```

## Invariant Check

For every `Types/X`, there must exist `Monads/[IO]MX`. Mechanically verifiable:

```
Types/Sovereignty/  -> Monads/MSovereignty/ + Monads/IOMSovereignty/   [OK]
Types/default.nix   -> Monads/IOMLeanPackage/                          [OK]
```

## Resources

- [awesome-osint](https://github.com/jivoi/awesome-osint)
- [awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted)
- [OSHWA](https://oshwa.org) - Open Source Hardware Association
- [Meshtastic](https://meshtastic.org) - Off-grid mesh
- [Reticulum](https://reticulum.network) - Cryptographic mesh
- [lean4-nix](https://github.com/lenianiva/lean4-nix) - Lean 4 Nix packaging
