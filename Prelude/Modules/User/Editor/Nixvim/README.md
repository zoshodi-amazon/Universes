# NIXVIM(7) - Neovim Configuration Module

## NAME

Nixvim - Neovim configuration via nixvim, capability-indexed plugin architecture

## SYNOPSIS

```
Modules/User/Editor/Nixvim/
├── Drv/asset-preview/  # Go sidecar: browser-based universal renderer
├── Env/
├── Instances/
└── Universe/Plugins/{Chrome,Inline,Render,Completion,Data,Git,Languages,Navigation,Nix}/
```

## DESCRIPTION

Nixvim module following the dendritic nix pattern. Plugins indexed by **rendering target capability**, not file type or tool name.

### Plugin Categories

| Category | Capability | Rendering Target | Contains |
|----------|-----------|-----------------|----------|
| **Chrome/** | Editor decoration | Editor UI itself | lualine, bufferline, which-key, web-devicons, indent-blankline, zen-mode |
| **Inline/** | In-buffer rendering | Inside nvim buffer | image.nvim, glow, d2-vim (ASCII) |
| **Render/** | External rendering | Browser window | asset-preview (universal), live-server, markdown-preview |
| **Completion/** | Input → suggestion | Popup menu | cmp, copilot |
| **Data/** | Structured data ops | Buffer transform | jq/yq formatting |
| **Git/** | Version control | Buffer + signs | gitsigns, fugitive |
| **Languages/** | Code intelligence | Buffer + float | LSP servers, REPLs |
| **Navigation/** | File/buffer traversal | Picker UI | telescope, oil, harpoon |
| **Nix/** | Nix-specific tooling | Buffer | nix LSP, formatting |

### Category Decision Tree

```
Does this plugin change how the EDITOR ITSELF looks?
  YES → Chrome/
  NO ↓

Does this plugin render content INSIDE a vim buffer?
  YES → Inline/
  NO ↓

Does this plugin render content in an EXTERNAL window/browser?
  YES → Render/
  NO ↓

Does it provide code intelligence for a language?
  YES → Languages/
  NO → Completion, Navigation, Data, Git, Nix (already clear)
```

## OPTIONS

Base options in `Universe/Core/Options/default.nix`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `nixvim.enable` | bool | false | Enable nixvim |
| `nixvim.colorscheme` | str | "tokyonight" | Color scheme |
| `nixvim.leader` | str | " " | Leader key |
| `nixvim.tabWidth` | int | 2 | Tab width |

Render options in `Universe/Plugins/Render/Options/default.nix`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `nixvim.preview.enable` | bool | false | Enable universal renderer |
| `nixvim.preview.port` | port | 9876 | Server port |
| `nixvim.preview.autoSwitch` | bool | true | Auto-switch on buffer change |
| `nixvim.preview.browser` | str | "open" | Browser launch command |
| `nixvim.preview.converters` | attrsOf str | (40+ mappings) | Extension → conversion command |

### Supported Formats (Render/)

| Category | Web-Native | Auto-Converted | Converter |
|----------|-----------|----------------|-----------|
| 2D Images | PNG, JPEG, WebP, GIF, SVG, BMP | EXR, HDR, TGA, TIFF, DDS | ffmpeg |
| Vector | SVG | EPS, AI | inkscape |
| 3D Models | glTF, GLB, OBJ, STL | FBX, DAE, 3DS, PLY, OFF | assimp |
| 3D CAD | — | STEP, IGES, BREP | freecad → assimp |
| Audio | MP3, OGG, WAV, FLAC, AAC | MIDI, MOD, XM, IT, S3M | ffmpeg/timidity |
| Video | MP4, WebM | AVI, MKV, MOV, FLV, WMV | ffmpeg |
| Shaders | GLSL, FRAG, VERT | HLSL, WGSL | naga |
| Diagrams | — | D2, Mermaid, Graphviz, PlantUML | d2/mmdc/dot/plantuml |
| Tilemaps | Tiled JSON | TMX (XML) | built-in |
| Fonts | TTF, OTF, WOFF, WOFF2 | — | — |
| Documents | Markdown, HTML, PDF | RST, ORG, AsciiDoc, LaTeX, Typst | pandoc/typst |
| Data | JSON, YAML, TOML, CSV | SQLite | sqlite3 |
| Scenes | .scene.json | — | three.js multi-asset |

## ENVIRONMENT

Keymaps organized by capability:

| Prefix | Category | Description |
|--------|----------|-------------|
| `<leader>c` | Computation | LSP, format, build |
| `<leader>i` | Inline | In-buffer rendering (glow, d2, image) |
| `<leader>s` | Signal | Diagnostics, logs |
| `<leader>m` | Meta | Help |
| `<leader>d` | Data | jq/yq format |
| `<leader>l` | Languages | REPL, infoview |
| `<leader>r` | Render | External browser rendering |

## DIAGNOSTICS

| Command | Description |
|---------|-------------|
| `:PreviewToggle` | Start/stop render server + browser |
| `:PreviewStop` | Stop render server |
| `:PreviewSend` | Manually send current file to renderer |

## CAVEATS

- Plugin keymaps MUST live with plugin Bindings (binding locality invariant)
- External plugins require sha256 hash from `nix-prefetch-url --unpack`
- New plugin dirs must be `git add`ed before rebuild (import-tree)
- Converters degrade gracefully — missing tools show warning, raw file served as fallback
- Browser import map required for three.js bare specifier resolution

## SEE ALSO

- `Arch.d2` - Visual diagram
- `~/repos/Universes/README.md` - Pattern documentation

## AUTHORS

Dendritic Nix pattern v1.0.5
