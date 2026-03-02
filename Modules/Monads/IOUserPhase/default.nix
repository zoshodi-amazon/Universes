# IOUserPhase (Gas) — user configuration
# 7 sub-phases: BEC → Crystalline → Liquid Crystal → Liquid → Gas → Plasma → QGP
{ ... }:
{
  imports = [
    ./Monads/IOIdentityPhase
    ./Monads/IOCredentialsPhase
    ./Monads/IOShellPhase
    ./Monads/IOTerminalPhase
    ./Monads/IOEditorPhase
    ./Monads/IOCommsPhase
    ./Monads/IOPackagesPhase
  ];
}
