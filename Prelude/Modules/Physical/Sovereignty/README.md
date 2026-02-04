# Sovereignty

Off-grid, surveillance-resistant autonomous living capability space.

**Threat Model**: Complete surveillance society, satellite tracking, dual-mode (evasion + gray man)

## Capability Space

### Survival Domains × OPSEC Layers

|              | Physical | Signal | Digital | Social | Financial | Temporal | Legal |
|--------------|----------|--------|---------|--------|-----------|----------|-------|
| **Energy**   | thermal, visual, acoustic | — | — | — | — | — | — |
| **Water**    | visual | — | — | — | — | — | — |
| **Food**     | thermal | — | — | — | — | — | — |
| **Shelter**  | thermal, visual, acoustic | — | — | — | — | — | — |
| **Medical**  | — | — | records | — | purchases | — | licensing |
| **Comms**    | — | RF, burst | metadata | patterns | — | timing | — |
| **Compute**  | — | EMI | trails | — | — | — | — |
| **Transport**| visual | electronic | tracking | patterns | tolls | timing | registration |
| **Defense**  | all | sensors | — | — | — | — | — |
| **Fabrication**| — | — | — | — | sourcing | — | regulated |
| **Intelligence**| — | passive | — | — | — | — | — |
| **Trade**    | — | — | — | — | anonymous | — | reporting |

### Operational Modes

| Mode | Purpose | Constraints |
|------|---------|-------------|
| `nomadic` | Mobile, rapid deploy/teardown | weight, volume, teardown time |
| `urban` | Gray man, blend in | cover identity, infrastructure use |
| `base` | Semi-permanent full capability | permanence, redundancy, expansion |

## Options

### Core (`sovereignty.*`)

| Option | Type | Default |
|--------|------|---------|
| `mode` | enum | `"base"` |
| `bootstrap.seed` | `knowledge\|energy\|compute` | `"knowledge"` |
| `fabrication.tier` | `assembly\|component\|material` | `"assembly"` |
| `opsec.{physical,signal,digital,social,financial,temporal,legal}.enable` | bool | varies |

### Energy (`sovereignty.energy.*`)

| Option | Type | Default |
|--------|------|---------|
| `generation.types` | list | `["solar"]` |
| `generation.capacity` | str | `"100W"` |
| `storage.capacity` | str | `"1kWh"` |
| `storage.chemistry` | enum | `"lifepo4"` |
| `distribution.voltage` | enum | `"12V"` |
| `signature.{thermal,acoustic,visual}` | enum | `"unmanaged"` |

### Comms (`sovereignty.comms.*`)

| Option | Type | Default |
|--------|------|---------|
| `mesh.enable` | bool | `false` |
| `mesh.protocol` | enum | `"meshtastic"` |
| `burst.enable` | bool | `false` |
| `encryption` | enum | `"chacha20"` |
| `rf.maxPower` | str | `"100mW"` |

### Intelligence (`sovereignty.intelligence.*`)

| Option | Type | Default |
|--------|------|---------|
| `osint.enable` | bool | `false` |
| `osint.domains` | list | `["social","geospatial","image"]` |
| `sigint.{enable,sdr,spectrum,protocol}` | bool | `false` |
| `countersurveillance.{enable,rf,camera,tscm}` | bool | `false` |
| `re.{software,hardware,firmware,protocol}` | bool | `false` |

### Compute (`sovereignty.compute.*`)

| Option | Type | Default |
|--------|------|---------|
| `architecture` | enum | `"aarch64"` |
| `openness` | `full\|partial\|pragmatic` | `"partial"` |
| `airgap.enable` | bool | `false` |
| `knowledge.static.enable` | bool | `false` |
| `knowledge.llm.enable` | bool | `false` |
| `knowledge.structured.enable` | bool | `false` |

## Hardware Openness

| Level | Description | Examples |
|-------|-------------|----------|
| `full` | Open ISA, open schematics, no blobs | RISC-V (VisionFive), Olimex |
| `partial` | Open schematics, some blobs | Pine64, BeagleBone |
| `pragmatic` | Closed but auditable/common | RPi (cover), commodity x86 |

## Usage

```bash
# Enter sovereignty devShell
nix develop .#sovereignty

# Discover tools for a domain
discover energy
discover intelligence --tool ghidra

# Energy calculator
energy calc --load 50W --hours 72
```

## Targets

| Target | Purpose |
|--------|---------|
| `perSystem.devShells.sovereignty` | Development/planning environment |
| `perSystem.packages.energy-monitor` | Energy monitoring tool |

## Resources

- [awesome-osint](https://github.com/jivoi/awesome-osint)
- [awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted)
- [OSHWA](https://oshwa.org) - Open Source Hardware Association
- [Meshtastic](https://meshtastic.org) - Off-grid mesh
- [Reticulum](https://reticulum.network) - Cryptographic mesh
