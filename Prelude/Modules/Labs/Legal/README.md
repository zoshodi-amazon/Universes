# Legal

Legal compliance reference and boundary awareness system.

## Capability

| Aspect | Description |
|--------|-------------|
| Category | Labs / Legal |
| Purpose | Reference source for legal permissibility across jurisdictions |
| Targets | devShells, checks |

## Global Duality

| Env | Instances |
|-----|-----------|
| Aggregates Universe/*/Options | Exports compliance checks, reference docs |

## Local Duality (Universe)

| Feature | Options | Bindings |
|---------|---------|----------|
| Employment | jurisdiction, employerPolicies | Scripts (policy lookup) |
| IP | workProduct, personalProjects | Hooks (boundary checks) |
| Privacy | dataHandling, piiAwareness | Commands (audit) |
| Licensing | ossCompliance, commercialUse | State (license tracker) |

## Jurisdictions

| Scope | Coverage |
|-------|----------|
| Federal | US federal employment, IP, privacy law |
| State | State-specific variations (TX, CA, etc.) |
| International | GDPR, international IP treaties |
| Corporate | Employer-specific policies, AUP |

## Key Boundaries

| Domain | Concern |
|--------|---------|
| Work Device Usage | Personal projects on company hardware |
| IP Assignment | Who owns code written when/where |
| Data Handling | PII, customer data, internal data |
| OSS Contribution | CLA requirements, employer approval |
| Moonlighting | Side project restrictions |

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `legal.enable` | bool | true | Enable legal module |
| `legal.jurisdiction.state` | string | — | Primary state jurisdiction |
| `legal.jurisdiction.country` | string | "US" | Primary country |
| `legal.employer.name` | string | — | Current employer |
| `legal.employer.policyPath` | path | — | Path to employer policy docs |
| `legal.workDevice` | bool | false | Is this a work-owned device |

## Bindings

| Category | Purpose |
|----------|---------|
| Scripts | Quick reference lookups (`legal-check`) |
| Commands | `legal audit`, `legal boundaries` |
| Hooks | Pre-commit IP boundary warnings |
| State | Track which projects are personal vs work |
