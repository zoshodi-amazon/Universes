import Lake
open Lake DSL

package «sov» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

@[default_target]
lean_exe «sov» where
  root := `Main