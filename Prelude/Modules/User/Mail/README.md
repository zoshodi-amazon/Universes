# Mail

CLI mail management via himalaya + posting. Terminal-native email for a solo research engineer lab.

## Structure

```
Mail/
├── Artifacts/
│   ├── NixMail/
│   │   └── default.nix          # Typed option space (accounts, auth, backends)
│   └── default.nix              # {} (import-tree)
├── Monads/
│   ├── IOMNixMail/
│   │   └── default.nix          # Effectful binding → programs.himalaya + posting
│   └── default.nix              # {} (import-tree)
├── default.nix                  # Global instantiation → flake.modules.homeManager.mail
├── justfile                     # Aggregation of all Monads as recipes
└── README.md
```

## Naming Convention

```
Artifacts/   → NixMail              — typed option module (Nix interpreter, Mail type)
Monads/      → IOMNixMail           — effectful monad (IO, Nix interpreter, Mail type)
Justfile     → [io-]nix-mail[-sub]  — kebab-case mirror
```

## Artifact/Monad 1-1 Mapping

| Artifact | Monad | IO? | Purpose |
|----------|-------|-----|---------|
| `NixMail` | `IOMNixMail` | effectful | Configure himalaya accounts, send mail |

## Options (NixMail Artifact — 6 dimensions per account)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `mail.enable` | bool | true | Capability toggle |
| `mail.defaultAccount` | str | "outlook" | Primary account name |
| `mail.accounts.<name>.email` | str | — | Account email address |
| `mail.accounts.<name>.backend` | enum [ imap maildir notmuch ] | "imap" | Read backend protocol |
| `mail.accounts.<name>.sendBackend` | enum [ smtp sendmail ] | "smtp" | Send backend protocol |
| `mail.accounts.<name>.host` | str | "outlook.office365.com" | IMAP/read host |
| `mail.accounts.<name>.sendHost` | str | "smtp-mail.outlook.com" | SMTP/send host |
| `mail.accounts.<name>.auth` | enum [ sops keyring command ] | "sops" | Auth method |

## Auth Methods

| Method | Mapping | Description |
|--------|---------|-------------|
| `sops` | `passwordCommand = "cat ${sops.secrets.mail-<name>-password.path}"` | Decrypt via sops-nix (default) |
| `keyring` | `passwordCommand = "secret-tool lookup mail <name>"` | OS system keychain |
| `command` | passthrough | Custom CLI command |

## Justfile Recipes

```bash
just nix-mail-options              # Print typed option space
just nix-mail                      # List envelopes (default account)
just nix-mail account=gmail        # List envelopes (specific account)
just nix-mail-read 42              # Read message by ID
just nix-mail-2fa                  # Recent subjects for 2FA extraction
just io-nix-mail-send              # Compose and send (opens $EDITOR)
just io-nix-mail-configure outlook # Interactive account setup (OAuth2)
```

## Usage

```bash
# List recent mail
himalaya envelope list

# JSON output for scripting
himalaya envelope list --output json | jq '.[0].subject'

# 2FA code extraction pipeline
himalaya envelope list --output json | jq -r '.[0:5] | .[].subject' | grep -oP '\d{6}'

# API testing via posting (TUI)
posting
```

## Supported Providers

himalaya supports any IMAP/SMTP provider. Documented configs:

| Provider | Host | Auth |
|----------|------|------|
| Outlook/M365 | outlook.office365.com | password, OAuth2 |
| Gmail | imap.gmail.com | App Password, OAuth2 |
| Proton Mail | 127.0.0.1 (via Bridge) | password |
| iCloud | imap.mail.me.com | App Password |

## Secrets (sops-nix)

Add account passwords to your `secrets.yaml`:

```yaml
mail-outlook-password: ENC[AES256_GCM,...]
mail-gmail-password: ENC[AES256_GCM,...]
```

The Monad maps `auth = "sops"` to `passwordCommand = "cat ${config.sops.secrets."mail-<name>-password".path}"`.

## Invariant Check

```
Artifacts/NixMail/  → Monads/IOMNixMail/   [OK]
```

## Tools

| Tool | Role |
|------|------|
| himalaya | CLI email client (IMAP/SMTP, OAuth2, JSON output) |
| posting | TUI API client (HTTP requests, collections, env vars) |
