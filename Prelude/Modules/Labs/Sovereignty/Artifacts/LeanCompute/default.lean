-- Compute artifact (6 params)
inductive Arch where | riscv64 | aarch64 | x86_64 deriving Repr, BEq, Inhabited
inductive Openness where | full | partial | pragmatic deriving Repr, BEq, Inhabited
inductive KnowledgeSource where | wikipedia | wikibooks | stackexchange | arxiv | gutenberg deriving Repr, BEq, Inhabited
inductive DataDomain where | plants | chemicals | electronics | medical | geology | astronomy deriving Repr, BEq, Inhabited
inductive LLMModel where | llama7b | llama13b | mistral7b | phi2 | codellama deriving Repr, BEq, Inhabited
structure Knowledge where sources : List KnowledgeSource := [.wikipedia, .wikibooks, .stackexchange]; llm : LLMModel := .llama7b; domains : List DataDomain := [.plants, .chemicals, .electronics, .medical]; items : List Item := [] deriving Repr, BEq, Inhabited

structure Compute where
  architecture : Arch := .aarch64
  openness : Openness := .partial
  airgap : Bool := false
  disposable : Bool := false
  knowledge : Knowledge := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited