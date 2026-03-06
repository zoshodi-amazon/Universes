import Lake
open Lake DSL

package «types» where
  leanOptions := #[⟨`autoImplicit, false⟩]
  srcDir := ".."

-- Category 1: Identity (BEC) — terminal objects
lean_lib «Identity» where
  roots := #[`Identity.Default]

-- Category 2: Inductive (Crystalline) — ADTs / sum types
lean_lib «Inductive» where
  roots := #[`Inductive.Default]

-- Category 3: Dependent (Liquid Crystal) — parameterized configs
lean_lib «Dependent» where
  roots := #[`Dependent.Default]

-- Category 4: Hom (Liquid) — phase input morphisms (top-level)
lean_lib «HomIdentity» where
  roots := #[`Hom.Identity.Default]

lean_lib «HomPlatform» where
  roots := #[`Hom.Platform.Default]

lean_lib «HomNetwork» where
  roots := #[`Hom.Network.Default]

lean_lib «HomServices» where
  roots := #[`Hom.Services.Default]

lean_lib «HomUser» where
  roots := #[`Hom.User.Default]

lean_lib «HomWorkspace» where
  roots := #[`Hom.Workspace.Default]

lean_lib «HomDeploy» where
  roots := #[`Hom.Deploy.Default]

-- Category 4: Hom (Liquid) — user sub-phase morphisms
lean_lib «HomUserIdentity» where
  roots := #[`Hom.User.Identity.Default]

lean_lib «HomUserCredentials» where
  roots := #[`Hom.User.Credentials.Default]

lean_lib «HomUserShell» where
  roots := #[`Hom.User.Shell.Default]

lean_lib «HomUserTerminal» where
  roots := #[`Hom.User.Terminal.Default]

lean_lib «HomUserEditor» where
  roots := #[`Hom.User.Editor.Default]

lean_lib «HomUserComms» where
  roots := #[`Hom.User.Comms.Default]

lean_lib «HomUserPackages» where
  roots := #[`Hom.User.Packages.Default]

-- Category 5: Product (Gas) — phase outputs (top-level)
lean_lib «ProductIdentityOutput» where
  roots := #[`Product.Identity.Output.Default]

lean_lib «ProductPlatformOutput» where
  roots := #[`Product.Platform.Output.Default]

lean_lib «ProductNetworkOutput» where
  roots := #[`Product.Network.Output.Default]

lean_lib «ProductServicesOutput» where
  roots := #[`Product.Services.Output.Default]

lean_lib «ProductUserOutput» where
  roots := #[`Product.User.Output.Default]

lean_lib «ProductWorkspaceOutput» where
  roots := #[`Product.Workspace.Output.Default]

lean_lib «ProductDeployOutput» where
  roots := #[`Product.Deploy.Output.Default]

-- Category 5: Product (Gas) — phase meta (top-level)
lean_lib «ProductIdentityMeta» where
  roots := #[`Product.Identity.Meta.Default]

lean_lib «ProductPlatformMeta» where
  roots := #[`Product.Platform.Meta.Default]

lean_lib «ProductNetworkMeta» where
  roots := #[`Product.Network.Meta.Default]

lean_lib «ProductServicesMeta» where
  roots := #[`Product.Services.Meta.Default]

lean_lib «ProductUserMeta» where
  roots := #[`Product.User.Meta.Default]

lean_lib «ProductWorkspaceMeta» where
  roots := #[`Product.Workspace.Meta.Default]

lean_lib «ProductDeployMeta» where
  roots := #[`Product.Deploy.Meta.Default]

-- Category 5: Product (Gas) — user sub-phase outputs
lean_lib «ProductUserIdentityOutput» where
  roots := #[`Product.User.Identity.Output.Default]

lean_lib «ProductUserCredentialsOutput» where
  roots := #[`Product.User.Credentials.Output.Default]

lean_lib «ProductUserShellOutput» where
  roots := #[`Product.User.Shell.Output.Default]

lean_lib «ProductUserTerminalOutput» where
  roots := #[`Product.User.Terminal.Output.Default]

lean_lib «ProductUserEditorOutput» where
  roots := #[`Product.User.Editor.Output.Default]

lean_lib «ProductUserCommsOutput» where
  roots := #[`Product.User.Comms.Output.Default]

lean_lib «ProductUserPackagesOutput» where
  roots := #[`Product.User.Packages.Output.Default]

-- Category 5: Product (Gas) — user sub-phase meta
lean_lib «ProductUserIdentityMeta» where
  roots := #[`Product.User.Identity.Meta.Default]

lean_lib «ProductUserCredentialsMeta» where
  roots := #[`Product.User.Credentials.Meta.Default]

lean_lib «ProductUserShellMeta» where
  roots := #[`Product.User.Shell.Meta.Default]

lean_lib «ProductUserTerminalMeta» where
  roots := #[`Product.User.Terminal.Meta.Default]

lean_lib «ProductUserEditorMeta» where
  roots := #[`Product.User.Editor.Meta.Default]

lean_lib «ProductUserCommsMeta» where
  roots := #[`Product.User.Comms.Meta.Default]

lean_lib «ProductUserPackagesMeta» where
  roots := #[`Product.User.Packages.Meta.Default]

-- Category 6: Monad (Plasma) — effect types
lean_lib «MonadTypes» where
  roots := #[`Monad.Default]

-- Category 7: IO (QGP) — validation entry point
@[default_target]
lean_exe «validate» where
  root := `IO.Default
