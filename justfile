# ===============================================================================
# UNIVERSES — Root Dispatcher
# ===============================================================================
#
# This justfile dispatches to lab-specific justfiles.
# Each lab is a self-contained typed artifact factory with its own justfile.
# No recipe duplication -- the dispatcher delegates, it does not implement.
#
# Every command is a classified morphism (6-functor formalism):
#
#   ana-{cmd}   — anamorphism  — coalgebraic observation (f*, f!, Hom)
#   cata-{cmd}  — catamorphism — algebraic production (f*, f!)
#   hylo-{cmd}  — hylomorphism — tensor composite: ana then cata (⊗)
#
# See AGENTS.md for full 6FF mapping. See TEMPLATE.md Section 7 for spec.
#
# ===============================================================================

default:
    @just --list

# ===============================================================================
# ana- (Anamorphism) — Coalgebraic observations → CoTypes/
# ===============================================================================

# f* pullback -- CoIO: launch opencode agent
ana-opencode:
    opencode

# f* pullback -- CoIO: enter nix-shell with package
ana-nix-shell pkg:
    nix-shell -p {{pkg}}

# ===============================================================================
# Lab Dispatchers — Delegate to lab-specific justfiles
# ===============================================================================

# f* pushforward -- SystemLab: system-level NixOS/nix-darwin configs (Lean 4 + Nix)
[group('labs')]
cata-system +ARGS:
    just -f SystemLab/justfile {{ARGS}}

# f* pushforward -- MaterialLab: physical material fabrication (Lean 4 + Python)
[group('labs')]
cata-material +ARGS:
    just -f MaterialLab/justfile {{ARGS}}

# f* pushforward -- RL-Lab: autonomous quant RL pipeline (Lean 4 + Python)
[group('labs')]
cata-rl +ARGS:
    just -f RL-Lab/justfile {{ARGS}}

# f* pushforward -- PlatformLab: hardware platform / firmware (Lean 4 + Rust)
[group('labs')]
cata-platform +ARGS:
    just -f PlatformLab/justfile {{ARGS}}

# f* pushforward -- HomeLab: user-level home-manager configs (Lean 4 + Nix)
[group('labs')]
cata-home +ARGS:
    just -f HomeLab/justfile {{ARGS}}
