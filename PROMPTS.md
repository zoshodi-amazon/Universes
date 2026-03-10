# PROMPTS.md

Canonical spec-driven prompt library for the Universes monorepo. Every prompt is a typed morphism: it has a clear input context, expected output, and invariant constraints. Use these prompts for subagent dispatch, parallel task execution, code reviews, audits, and all spec-driven development.

Lab-specific PROMPTS.md files extend this document with domain-specific prompts.

---

## How To Use

1. **Copy the prompt verbatim** (or with minimal parameter substitution) into a subagent, chat session, or task dispatcher.
2. **Substitute `{Lab}`, `{Phase}`, `{Stratum}`** etc. with concrete values.
3. **Every prompt references the canonical docs** — the subagent should read them before executing.
4. **Prompts are composable** — chain multiple prompts for multi-step workflows.

---

## 1. Audit Prompts

### 1.1 Full Type System Audit

```
Read {Lab}/AGENTS.md and the root Universes/AGENTS.md. Then perform a full audit:

1. Verify all 34 universal invariants (root AGENTS.md) against {Lab}/ code.
2. For each stratum (Identity through IO), count:
   - Number of directories
   - Number of types per directory
   - Number of fields per type (flag any >7)
3. Verify 1-1 CoTypes duality: every Types/ category has exactly one CoTypes/ dual.
4. Verify the import DAG: no upward imports (Identity <- Inductive <- Dependent <- Hom <- Product; Monad and IO terminal).
5. Verify all filenames are `default.*` (only exceptions: `__init__.py`, language-mandated files).
6. Report: PASS/FAIL per invariant, with evidence for any FAIL.
```

### 1.2 Git Status Sweep Audit

```
Run `git status --short` in the repo root. Classify ALL uncommitted changes:

1. By lab: which labs have changes?
2. By change type: Modified (M), Renamed (R/RM), Added (A), Deleted (D), Untracked (??)
3. By stratum: for each lab, which strata are affected?
4. Flag any files that should NOT be committed (.env, credentials, __pycache__, .DS_Store).
5. Flag any untracked files that look like they should be tracked.
6. Report a summary table: Lab | Change Type | Count | Files
```

### 1.3 Naming Normalization Audit

```
Read {Lab}/DICTIONARY.md (Naming Normalization Table) and root TEMPLATE.md Section 16 (Naming Normalization Protocol).

For every Python file in {Lab}/Types/ and {Lab}/CoTypes/:
1. Extract all class names, field names, method names, and enum variant names.
2. Compare against the normalization table in DICTIONARY.md.
3. Flag any name that uses domain jargon where a category-theoretic name exists.
4. Flag any name that does not follow the `{Domain}{Stratum}` suffix convention.
5. Report: file path, old name, expected new name, status (RENAMED / STILL OLD).
```

### 1.4 JSON Fidelity Audit

```
For every `default.json` in {Lab}/Types/IO/ and {Lab}/CoTypes/CoIO/:

1. Read the corresponding `default.py` Settings class.
2. Read the `default.json` file.
3. Verify roundtrip closure: every field in Settings has a corresponding key in JSON, and vice versa.
4. Verify no null values (invariant 9).
5. Verify all field names match the current type definitions (not stale old names).
6. Report: phase, file, PASS/FAIL, details of any mismatch.
```

### 1.5 Import Path Audit

```
For every Python file in {Lab}/Types/ and {Lab}/CoTypes/:

1. Extract all import statements.
2. Verify each import path resolves to an existing file.
3. Verify the import DAG is respected: no upward imports (Identity <- Inductive <- Dependent <- Hom <- Product).
4. Verify no cross-Hom imports (shared types must be in Identity, Inductive, or Dependent).
5. Verify all imports are fully qualified (no wildcards, no relative imports).
6. Report: file, import, PASS/FAIL, violation type.
```

### 1.6 Field Count Audit

```
For every type definition in {Lab}/Types/ and {Lab}/CoTypes/:

1. Count the number of fields on each BaseModel/pydantic type.
2. Flag any type with >7 fields (violates invariant 15).
3. Verify every field has `Field(description=...)`.
4. Verify every numeric field has bounds (`ge=`/`le=`).
5. Verify every string field has constraints (`min_length=`/`max_length=`).
6. Report: type name, file path, field count, any violations.
```

---

## 2. Code Review Prompts

### 2.1 Type Definition Review

```
Review the type definition in {FilePath}. Check against root AGENTS.md and {Lab}/AGENTS.md:

1. Is the type in the correct stratum? (Identity = 1 inhabitant, Inductive = ADT/enum, Dependent = parameterized, Hom = phase input, Product = phase output, Monad = effect, IO = executor)
2. Does the class name follow `{Domain}{Stratum}` convention?
3. Are all fields bounded (ge/le, min_length/max_length)?
4. Are there <=7 fields?
5. Is there exactly one type per file?
6. Does every field have `Field(description=...)`?
7. Are there any bare strings that should be Inductive ADTs?
8. Are there any None/Optional types (should be sentinel values)?
9. Is the docstring accurate and includes stratum annotation?
10. Report: PASS/FAIL per check, with specific fix instructions for any FAIL.
```

### 2.2 IO Executor Review

```
Review the IO executor in {FilePath}. Check against root AGENTS.md and {Lab}/AGENTS.md:

1. Does it have its own BaseSettings class?
2. Does it read from default.json at the IO boundary?
3. Does it have a `run()` function with typed return?
4. Does it have a `__main__` block?
5. Are there any bare `try`/`except` blocks? (Should use @safe/@impure_safe from dry-python/returns)
6. Does it return IOResult[T, ErrorMonad]?
7. Does it import types only from Types/ (not defining its own)?
8. Are all external data wrapped through Inductive types before use?
9. Is the profunctor pattern respected? (Hom -> IO executor -> Product)
10. Report: PASS/FAIL per check, with specific fix instructions for any FAIL.
```

### 2.3 CoIO Observer Review

```
Review the CoIO observer in {FilePath}. Check against root AGENTS.md and {Lab}/AGENTS.md:

1. Does it follow the observation triad? (CoHom -> CoIO observer -> CoProduct)
2. Does it only READ from the external world (no mutations)?
3. Does it probe the StoreMonad for the corresponding phase artifact?
4. Does it populate CoProduct fields based on observation?
5. Is there a corresponding `ana-{phase}` justfile command?
6. Does the `default.json` match the Settings fields?
7. Report: PASS/FAIL per check.
```

---

## 3. Implementation Prompts

### 3.1 Add New Type

```
Add a new type to {Lab}/Types/{Stratum}/{TypeDir}/. Follow root AGENTS.md and TEMPLATE.md:

1. Read root AGENTS.md (all 34 invariants) and {Lab}/AGENTS.md.
2. Create directory `{Lab}/Types/{Stratum}/{TypeDir}/`.
3. Create `{Lab}/Types/{Stratum}/{TypeDir}/__init__.py` (empty).
4. Create `{Lab}/Types/{Stratum}/{TypeDir}/default.py` with:
   - Module docstring: `"""{ClassName} [{Stratum}] -- {description} ({N} fields)."""`
   - Single class inheriting from BaseModel
   - <=7 fields, all bounded, all with `Field(description=...)`
   - No None/Optional, use sentinel defaults
5. Create the CoTypes dual: `{Lab}/CoTypes/Co{Stratum}/{TypeDir}/` with matching structure.
6. Update DICTIONARY.md with the new type entry.
7. Update TRACKER.md with the change.
```

### 3.2 Add New Phase

```
Add a new phase to {Lab}. Follow root AGENTS.md (invariant 14: 1-1-1) and {Lab}/AGENTS.md:

1. Read frozen phase chain in {Lab}/AGENTS.md. Verify the new phase fits.
2. Create the profunctor triad:
   - `Types/Hom/{Phase}/default.py` — phase input Hom type
   - `Types/Product/{Phase}/Output/default.py` — phase output type
   - `Types/Product/{Phase}/Meta/default.py` — phase meta type
   - `Types/IO/IO{Phase}Phase/default.py` — IO executor
   - `Types/IO/IO{Phase}Phase/default.json` — serialized Hom
3. Create the observation dual:
   - `CoTypes/CoHom/{Phase}/default.py` — observation spec
   - `CoTypes/CoProduct/{Phase}/Output/default.py` — observation result output
   - `CoTypes/CoProduct/{Phase}/Meta/default.py` — observation result meta
   - `CoTypes/CoIO/CoIO{Phase}Phase/default.py` — observer executor
   - `CoTypes/CoIO/CoIO{Phase}Phase/default.json` — serialized CoHom
4. Add justfile entries: `cata-{phase}` and `ana-{phase}`.
5. Update all frozen tables in AGENTS.md, README.md.
6. Update DICTIONARY.md, TRACKER.md.
```

### 3.3 Rename Type/Field/Phase

```
Execute a rename in {Lab}/. Reference {Lab}/DICTIONARY.md normalization table:

1. Read the normalization table in {Lab}/DICTIONARY.md for the complete mapping.
2. For directory renames: `git mv {old_path} {new_path}` for each affected directory.
3. For class renames inside files: update class name, docstring, all string references.
4. For field renames: update field declaration, description, all call sites.
5. For method renames: update method definition, all call sites across IO executors.
6. Update all `default.json` files with new field names.
7. Update all `__init__.py` import paths.
8. Run `rg '{old_name}'` across entire {Lab}/ to find any remaining references.
9. Update justfile if phase names changed.
10. Update TRACKER.md with the changes.
```

### 3.4 Integrate dry-python/returns

```
Wrap {Lab} IO executors with dry-python/returns monadic surface (root AGENTS.md invariant 34):

1. Verify `returns>=0.23` is in pyproject.toml dependencies.
2. For each IO executor in Types/IO/:
   - Import: `from returns.result import Result, safe` and `from returns.io import IOResult, impure_safe`
   - Wrap the `run()` function return type as `IOResult[{ProductType}, ErrorMonad]`
   - Replace bare `try`/`except` with `@impure_safe` decorator
   - Replace pure fallible computations with `@safe` decorator
3. For StoreMonad:
   - Import: `from returns.maybe import Maybe`
   - Wrap lookup methods to return `Maybe[ArtifactMonad]`
4. For IOComposePhase:
   - Use `flow()` / `pipe()` for pipeline composition
5. Run type checker to verify returns types propagate correctly.
```

---

## 4. Documentation Prompts

### 4.1 Update TRACKER.md

```
Read {Lab}/TRACKER.md. Add a new session entry at the top (after header, before previous session):

## {Date} -- Session {N}: {Title}

### What happened
- {Bullet list of changes made}

### Changes
| File | What Changed |
|------|-------------|
| {file} | {description} |

### Session {N} Roadmap
| # | Task | Status |
|---|------|--------|
| T{N}.1 | {task} | {DONE/OPEN/DEFERRED} |

Ensure the entry follows the exact format of previous entries. Update any roadmap tables that reference completed work.
```

### 4.2 Update DICTIONARY.md

```
Read {Lab}/DICTIONARY.md. For each new or renamed term:

1. Find the correct alphabetical section (A, C, D, E, F, etc.).
2. Add or update the entry with:
   - **What:** one-line definition
   - **Where:** file path
   - **Phase:** type-theoretic phase (matter state)
   - **Fields:** field list (if applicable)
3. If renaming, update the Naming Normalization Table.
4. Ensure no stale references to old names remain.
```

### 4.3 Reconcile Docs Against Code

```
Perform a full docs-code reconciliation for {Lab}/:

1. Read AGENTS.md, README.md, DICTIONARY.md, TEMPLATE.md, TRACKER.md.
2. For every type mentioned in docs, verify it exists in code at the stated path.
3. For every type in code, verify it is documented.
4. For every justfile command in docs, verify it exists in justfile.
5. For every field count mentioned in docs, verify against actual code.
6. Report all drift: doc says X, code says Y.
7. Propose fixes for each drift item.
```

---

## 5. Verification Prompts

### 5.1 Full Verification Sweep

```
Run a full verification sweep for {Lab}/:

1. `rg '{old_name_pattern}'` across all files to find stale references.
2. Verify all import paths resolve (no broken imports).
3. Verify all `default.json` files have correct field names.
4. Verify justfile commands point to correct module paths.
5. If Python: `ruff check {Lab}/Types/ {Lab}/CoTypes/` for lint.
6. If Python: `pyright {Lab}/` for type checking.
7. Report: category, PASS/FAIL count, specific failures.
```

### 5.2 Roundtrip Closure Test

```
For every Hom type in {Lab}/Types/Hom/:

1. Instantiate the type with defaults: `hom = {HomType}()`
2. Serialize to JSON: `json_str = hom.model_dump_json()`
3. Deserialize back: `hom2 = {HomType}.model_validate_json(json_str)`
4. Assert `hom == hom2` (roundtrip closure).
5. Compare against the committed `default.json` — it should match `hom.model_dump_json()`.
6. Report: phase, PASS/FAIL, any drift between committed JSON and generated JSON.
```

### 5.3 Profunctor Triad Completeness

```
For every phase in {Lab}/:

1. Verify the production triad exists: Hom + ProductOutput + ProductMeta + IO executor + default.json
2. Verify the observation triad exists: CoHom + CoProductOutput + CoProductMeta + CoIO observer + default.json
3. Verify the justfile has both `cata-{phase}` and `ana-{phase}` entries.
4. Report: phase, triad component, EXISTS/MISSING.
```

---

## 6. Subagent Dispatch Patterns

### 6.1 Parallel Stratum Audit

Dispatch 7 subagents in parallel, one per stratum:

```
For stratum {N} ({StratumName}) in {Lab}/:
- Read all files in Types/{StratumName}/ and CoTypes/Co{StratumName}/
- Count types, fields, verify naming, check bounds
- Report: type count, field counts, any invariant violations
```

### 6.2 Parallel Phase Audit

Dispatch one subagent per phase:

```
For phase {Phase} in {Lab}/:
- Read Types/Hom/{Phase}/default.py
- Read Types/Product/{Phase}/Output/default.py and Meta/default.py
- Read Types/IO/IO{Phase}Phase/default.py and default.json
- Read CoTypes/CoHom/{Phase}/default.py
- Read CoTypes/CoProduct/{Phase}/Output/default.py and Meta/default.py
- Read CoTypes/CoIO/CoIO{Phase}Phase/default.py and default.json
- Verify profunctor triad completeness, naming, field counts, JSON fidelity
- Report per-phase: PASS/FAIL with evidence
```

### 6.3 Parallel File Rename

Dispatch one subagent per stratum for mechanical renames:

```
For stratum {N} ({StratumName}) in {Lab}/:
- Read {Lab}/DICTIONARY.md normalization table for this stratum
- For each directory rename: `git mv {old} {new}`
- For each file: update class name, field names, method names, docstrings
- Update all `__init__.py` exports
- Report: files changed, renames applied
```

---

## 7. Git Prompts

### 7.1 Commit Format

```
[{Lab} | {Category}] v{Version}: {description}

Categories: Docs, Code, Refactor, IO, CoIO, Types, Fix, Audit
Examples:
  [RL-Lab | Docs] v0.4.0: Session 6 implementation plan
  [RL-Lab | Refactor] v0.4.0: Execute taxonomic purification
  [Docs | IO] v7.3.0: Justfile 6FF typing standardization
```

### 7.2 Pre-Commit Audit

```
Before committing, verify:
1. No .env, credentials, or secret files are staged.
2. No __pycache__ directories are staged.
3. No .DS_Store files are staged.
4. All staged files belong to the correct lab/stratum.
5. The commit message follows the format: [{Lab} | {Category}] v{Version}: {description}
6. Run `git diff --staged --stat` to review the scope.
```
