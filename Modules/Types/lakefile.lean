import Lake
open Lake DSL

package «types» where
  leanOptions := #[⟨`autoImplicit, false⟩]

lean_lib «UnitTypes» where
  roots := #[`UnitTypes.Default]

lean_lib «IdentityInput» where
  roots := #[`PhaseInputTypes.IdentityInput.Default]

lean_lib «PlatformInput» where
  roots := #[`PhaseInputTypes.PlatformInput.Default]

lean_lib «NetworkInput» where
  roots := #[`PhaseInputTypes.NetworkInput.Default]

lean_lib «ServicesInput» where
  roots := #[`PhaseInputTypes.ServicesInput.Default]

lean_lib «UserInput» where
  roots := #[`PhaseInputTypes.UserInput.Default]

lean_lib «WorkspaceInput» where
  roots := #[`PhaseInputTypes.WorkspaceInput.Default]

lean_lib «DeployInput» where
  roots := #[`PhaseInputTypes.DeployInput.Default]

@[default_target]
lean_exe «validate» where
  root := `Default
