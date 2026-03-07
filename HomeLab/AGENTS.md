# HomeLab AGENTS.md

## Domain
User-level home-manager configurations. Artifact type: `homeConfigurations`.

## Invariants
1. One type per file — one `inductive` or `structure` per `Default.lean`
2. IO/ capped at exactly 7 subdirectories (the 7 canonical phases)
3. `local.json` for deployment-site secrets — never committed
4. Lean types are source of truth; JSON is the typed boundary; Nix is the IO executor
5. Types/ and CoTypes/ maintain 1:1 duality correspondence
6. Minimal orthogonal generating set at each stratum
