import Lake
open Lake DSL

package «types» where
  leanOptions := #[⟨`autoImplicit, false⟩]
  srcDir := "../.."

-- ============================================================================
-- Types/ — Algebraic (production, catamorphic)
-- ============================================================================

-- Category 1: Identity (BEC) — terminal objects
lean_lib «Identity» where
  roots := #[`Types.Identity.Default]

-- Category 2: Inductive (Crystalline) — ADTs / sum types (1-type-per-file)
lean_lib «InductiveBootLoader» where
  roots := #[`Types.Inductive.BootLoader.Default]

lean_lib «InductiveDisplayBackend» where
  roots := #[`Types.Inductive.DisplayBackend.Default]

lean_lib «InductiveDisplayGreeter» where
  roots := #[`Types.Inductive.DisplayGreeter.Default]

lean_lib «InductiveContainerBackend» where
  roots := #[`Types.Inductive.ContainerBackend.Default]

lean_lib «InductiveGcInterval» where
  roots := #[`Types.Inductive.GcInterval.Default]

lean_lib «InductiveSovereigntyMode» where
  roots := #[`Types.Inductive.SovereigntyMode.Default]

lean_lib «InductiveSearchEngine» where
  roots := #[`Types.Inductive.SearchEngine.Default]

lean_lib «InductiveAIProvider» where
  roots := #[`Types.Inductive.AIProvider.Default]

lean_lib «InductiveMachineArch» where
  roots := #[`Types.Inductive.MachineArch.Default]

lean_lib «InductiveMachineFormat» where
  roots := #[`Types.Inductive.MachineFormat.Default]

lean_lib «InductiveShellEditor» where
  roots := #[`Types.Inductive.ShellEditor.Default]

lean_lib «InductiveTmuxPrefix» where
  roots := #[`Types.Inductive.TmuxPrefix.Default]

lean_lib «InductiveKittyTheme» where
  roots := #[`Types.Inductive.KittyTheme.Default]

lean_lib «InductiveColorscheme» where
  roots := #[`Types.Inductive.Colorscheme.Default]

lean_lib «InductiveGitBranch» where
  roots := #[`Types.Inductive.GitBranch.Default]

lean_lib «InductiveCloudOutputFormat» where
  roots := #[`Types.Inductive.CloudOutputFormat.Default]

lean_lib «InductiveDiskLayout» where
  roots := #[`Types.Inductive.DiskLayout.Default]

lean_lib «InductivePersistenceStrategy» where
  roots := #[`Types.Inductive.PersistenceStrategy.Default]

lean_lib «InductiveHardwareProfile» where
  roots := #[`Types.Inductive.HardwareProfile.Default]

lean_lib «InductiveGpuDriver» where
  roots := #[`Types.Inductive.GpuDriver.Default]

lean_lib «InductiveAudioBackend» where
  roots := #[`Types.Inductive.AudioBackend.Default]

-- Re-export all Inductive types
lean_lib «Inductive» where
  roots := #[`Types.Inductive.Default]

-- Category 3: Dependent (Liquid Crystal) — parameterized configs (1-type-per-file)
lean_lib «DependentNixSettings» where
  roots := #[`Types.Dependent.NixSettings.Default]

lean_lib «DependentSopsConfig» where
  roots := #[`Types.Dependent.SopsConfig.Default]

lean_lib «DependentBootConfig» where
  roots := #[`Types.Dependent.BootConfig.Default]

lean_lib «DependentDisplayConfig» where
  roots := #[`Types.Dependent.DisplayConfig.Default]

lean_lib «DependentNetworkConfig» where
  roots := #[`Types.Dependent.NetworkConfig.Default]

lean_lib «DependentSshConfig» where
  roots := #[`Types.Dependent.SshConfig.Default]

lean_lib «DependentContainerConfig» where
  roots := #[`Types.Dependent.ContainerConfig.Default]

lean_lib «DependentSovereigntyConfig» where
  roots := #[`Types.Dependent.SovereigntyConfig.Default]

lean_lib «DependentGitConfig» where
  roots := #[`Types.Dependent.GitConfig.Default]

lean_lib «DependentBrowserConfig» where
  roots := #[`Types.Dependent.BrowserConfig.Default]

lean_lib «DependentAIConfig» where
  roots := #[`Types.Dependent.AIConfig.Default]

lean_lib «DependentCloudConfig» where
  roots := #[`Types.Dependent.CloudConfig.Default]

lean_lib «DependentHomeTarget» where
  roots := #[`Types.Dependent.HomeTarget.Default]

lean_lib «DependentHomeTargets» where
  roots := #[`Types.Dependent.HomeTargets.Default]

lean_lib «DependentMachineConfig» where
  roots := #[`Types.Dependent.MachineConfig.Default]

lean_lib «DependentDiskConfig» where
  roots := #[`Types.Dependent.DiskConfig.Default]

lean_lib «DependentPersistenceConfig» where
  roots := #[`Types.Dependent.PersistenceConfig.Default]

lean_lib «DependentMachineUser» where
  roots := #[`Types.Dependent.MachineUser.Default]

lean_lib «DependentHardwareConfig» where
  roots := #[`Types.Dependent.HardwareConfig.Default]

-- Re-export all Dependent types
lean_lib «Dependent» where
  roots := #[`Types.Dependent.Default]

-- Category 4: Hom (Liquid) — phase input morphisms (top-level)
lean_lib «HomIdentity» where
  roots := #[`Types.Hom.Identity.Default]

lean_lib «HomPlatform» where
  roots := #[`Types.Hom.Platform.Default]

lean_lib «HomNetwork» where
  roots := #[`Types.Hom.Network.Default]

lean_lib «HomServices» where
  roots := #[`Types.Hom.Services.Default]

lean_lib «HomUser» where
  roots := #[`Types.Hom.User.Default]

lean_lib «HomWorkspace» where
  roots := #[`Types.Hom.Workspace.Default]

lean_lib «HomDeploy» where
  roots := #[`Types.Hom.Deploy.Default]

-- Category 4: Hom (Liquid) — user sub-phase morphisms
lean_lib «HomUserIdentity» where
  roots := #[`Types.Hom.User.Identity.Default]

lean_lib «HomUserCredentials» where
  roots := #[`Types.Hom.User.Credentials.Default]

lean_lib «HomUserShell» where
  roots := #[`Types.Hom.User.Shell.Default]

lean_lib «HomUserTerminal» where
  roots := #[`Types.Hom.User.Terminal.Default]

lean_lib «HomUserEditor» where
  roots := #[`Types.Hom.User.Editor.Default]

lean_lib «HomUserComms» where
  roots := #[`Types.Hom.User.Comms.Default]

lean_lib «HomUserPackages» where
  roots := #[`Types.Hom.User.Packages.Default]

-- Category 5: Product (Gas) — phase outputs (top-level)
lean_lib «ProductIdentityOutput» where
  roots := #[`Types.Product.Identity.Output.Default]

lean_lib «ProductPlatformOutput» where
  roots := #[`Types.Product.Platform.Output.Default]

lean_lib «ProductNetworkOutput» where
  roots := #[`Types.Product.Network.Output.Default]

lean_lib «ProductServicesOutput» where
  roots := #[`Types.Product.Services.Output.Default]

lean_lib «ProductUserOutput» where
  roots := #[`Types.Product.User.Output.Default]

lean_lib «ProductWorkspaceOutput» where
  roots := #[`Types.Product.Workspace.Output.Default]

lean_lib «ProductDeployOutput» where
  roots := #[`Types.Product.Deploy.Output.Default]

-- Category 5: Product (Gas) — phase meta (top-level)
lean_lib «ProductIdentityMeta» where
  roots := #[`Types.Product.Identity.Meta.Default]

lean_lib «ProductPlatformMeta» where
  roots := #[`Types.Product.Platform.Meta.Default]

lean_lib «ProductNetworkMeta» where
  roots := #[`Types.Product.Network.Meta.Default]

lean_lib «ProductServicesMeta» where
  roots := #[`Types.Product.Services.Meta.Default]

lean_lib «ProductUserMeta» where
  roots := #[`Types.Product.User.Meta.Default]

lean_lib «ProductWorkspaceMeta» where
  roots := #[`Types.Product.Workspace.Meta.Default]

lean_lib «ProductDeployMeta» where
  roots := #[`Types.Product.Deploy.Meta.Default]

-- Category 5: Product (Gas) — user sub-phase outputs
lean_lib «ProductUserIdentityOutput» where
  roots := #[`Types.Product.User.Identity.Output.Default]

lean_lib «ProductUserCredentialsOutput» where
  roots := #[`Types.Product.User.Credentials.Output.Default]

lean_lib «ProductUserShellOutput» where
  roots := #[`Types.Product.User.Shell.Output.Default]

lean_lib «ProductUserTerminalOutput» where
  roots := #[`Types.Product.User.Terminal.Output.Default]

lean_lib «ProductUserEditorOutput» where
  roots := #[`Types.Product.User.Editor.Output.Default]

lean_lib «ProductUserCommsOutput» where
  roots := #[`Types.Product.User.Comms.Output.Default]

lean_lib «ProductUserPackagesOutput» where
  roots := #[`Types.Product.User.Packages.Output.Default]

-- Category 5: Product (Gas) — user sub-phase meta
lean_lib «ProductUserIdentityMeta» where
  roots := #[`Types.Product.User.Identity.Meta.Default]

lean_lib «ProductUserCredentialsMeta» where
  roots := #[`Types.Product.User.Credentials.Meta.Default]

lean_lib «ProductUserShellMeta» where
  roots := #[`Types.Product.User.Shell.Meta.Default]

lean_lib «ProductUserTerminalMeta» where
  roots := #[`Types.Product.User.Terminal.Meta.Default]

lean_lib «ProductUserEditorMeta» where
  roots := #[`Types.Product.User.Editor.Meta.Default]

lean_lib «ProductUserCommsMeta» where
  roots := #[`Types.Product.User.Comms.Meta.Default]

lean_lib «ProductUserPackagesMeta» where
  roots := #[`Types.Product.User.Packages.Meta.Default]

-- Category 6: Monad (Plasma) — effect types
lean_lib «MonadTypes» where
  roots := #[`Types.Monad.Default]

-- ============================================================================
-- CoTypes/ — Coalgebraic dual (1-1 correspondence with Types/)
-- ============================================================================

-- CoCategory 1: CoIdentity — coterminal introspection witnesses
lean_lib «CoIdentity» where
  roots := #[`CoTypes.CoIdentity.Default]

-- CoCategory 2: CoInductive — cofree elimination forms, validators
lean_lib «CoInductive» where
  roots := #[`CoTypes.CoInductive.Default]

-- CoCategory 3: CoDependent — cofibration schema conformance
lean_lib «CoDependent» where
  roots := #[`CoTypes.CoDependent.Default]

-- CoCategory 4: CoHom — observation specifications (field-parallel to Hom/)
lean_lib «CoHom» where
  roots := #[`CoTypes.CoHom.Default]

-- CoCategory 5: CoProduct — observation results (Output + Meta)
lean_lib «CoProduct» where
  roots := #[`CoTypes.CoProduct.Default]

-- CoCategory 6: Comonad — observation traces (extract + extend)
lean_lib «ComonadTypes» where
  roots := #[`CoTypes.Comonad.Default]

-- CoCategory 7: CoIO — observer result types
lean_lib «CoIO» where
  roots := #[`CoTypes.CoIO.Default]

-- Category 7: IO (QGP) — validation entry point
@[default_target]
lean_exe «validate» where
  root := `Types.IO.Default
