# Browsers

Hardened Firefox with maximum security settings.

## Structure

```
Browsers/
├── Types/
│   ├── NixBrowser/default.nix   # Options (enable, search.default)
│   └── default.nix
├── Monads/
│   ├── IOMNixBrowser/default.nix
│   └── default.nix
├── default.nix                  # → flake.modules.homeManager.browser
└── README.md
```

## Hardening (always-max)

- Telemetry, crash reports, studies: disabled
- Pocket, sponsored content: disabled
- Fingerprinting resistance: enabled
- Tracking protection: all categories
- WebRTC: disabled (leak prevention)
- HTTPS-only mode: enabled
- Form autofill, password saving: disabled
- DNS over HTTPS: enabled
- Prefetch, speculative connections: disabled

## Extensions (via policies, force-installed)

- uBlock Origin — ad/tracker blocking
- Vimium — keyboard navigation
- Dark Reader — dark theme

## Invariant Check

```
Types/NixBrowser/  → Monads/IOMNixBrowser/   [OK]
```
