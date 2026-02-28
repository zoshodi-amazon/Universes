# Docs

Presentations and documentation artifacts rendered via presenterm.

## Run

```bash
nix-shell -p presenterm --run "presenterm Modules/Labs/Docs/self-hosted-spectrum.md"
```

## Presentations

| File | Topic |
|------|-------|
| `self-hosted-spectrum.md` | Self-hosted capability spectrum — security, compute, services, validation |

## Presenterm Features Used

| Feature | Syntax |
|---------|--------|
| Front matter | `---` YAML block with title, sub_title, author |
| Slide separator | `<!-- end_slide -->` |
| Setext headings | `Title` + `===` underline |
| Formatted text | `**bold**`, `_italic_`, `~~strike~~`, `` `code` `` |
| Code blocks | Fenced with language (nix, bash) |
| Tables | Pipe-delimited markdown tables |
| Columns | `<!-- column_layout: [1, 1] -->` + `<!-- column: N -->` |
| Pauses | `<!-- pause -->` for incremental reveal |
| Colored text | `<span style="color: #hex">` |
| Speaker notes | `<!-- speaker_note: ... -->` |
| Lists | Ordered (`1.`) and unordered (`-`) |
| Block quotes | `>` prefix |

## Navigation

| Key | Action |
|-----|--------|
| `→` / `l` / `space` | Next slide |
| `←` / `h` | Previous slide |
| `gg` | First slide |
| `G` | Last slide |
| `?` | Show key bindings |
| `ctrl+c` | Exit |
