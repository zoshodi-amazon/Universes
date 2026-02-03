# Preview plugins - live renderers for all artifact types
# Filetype → Interpreter duality
{ config, lib, ... }:
{
  config.nixvim.keymaps.preview = lib.mkIf config.nixvim.enable [
    # ─────────────────────────────────────────────────────────────
    # Diagrams
    # ─────────────────────────────────────────────────────────────
    { mode = "n"; key = "<leader>pd"; action = "<cmd>!d2 --watch % %:r.svg &<cr>"; options.desc = "D2 live"; }
    { mode = "n"; key = "<leader>pm"; action = "<cmd>!mmdc -i % -o %:r.svg && open %:r.svg<cr>"; options.desc = "Mermaid render"; }
    { mode = "n"; key = "<leader>pg"; action = "<cmd>!dot -Tsvg % -o %:r.svg && open %:r.svg<cr>"; options.desc = "Graphviz render"; }
    { mode = "n"; key = "<leader>pu"; action = "<cmd>!plantuml -tsvg % && open %:r.svg<cr>"; options.desc = "PlantUML render"; }

    # ─────────────────────────────────────────────────────────────
    # CAD/3D
    # ─────────────────────────────────────────────────────────────
    { mode = "n"; key = "<leader>p3"; action = "<cmd>!f3d %<cr>"; options.desc = "3D preview (f3d)"; }
    { mode = "n"; key = "<leader>ps"; action = "<cmd>!openscad %<cr>"; options.desc = "OpenSCAD preview"; }

    # ─────────────────────────────────────────────────────────────
    # Docs
    # ─────────────────────────────────────────────────────────────
    { mode = "n"; key = "<leader>pt"; action = "<cmd>!typst watch % &<cr>"; options.desc = "Typst live"; }
    { mode = "n"; key = "<leader>pz"; action = "<cmd>!zathura %:r.pdf &<cr>"; options.desc = "Open PDF"; }
    { mode = "n"; key = "<leader>pw"; action = "<cmd>!glow %<cr>"; options.desc = "Markdown preview"; }

    # ─────────────────────────────────────────────────────────────
    # Media
    # ─────────────────────────────────────────────────────────────
    { mode = "n"; key = "<leader>pv"; action = "<cmd>!mpv %<cr>"; options.desc = "Video (mpv)"; }
    { mode = "n"; key = "<leader>pi"; action = "<cmd>!inkscape %<cr>"; options.desc = "SVG (inkscape)"; }
    { mode = "n"; key = "<leader>pa"; action = "<cmd>!ffplay -autoexit %<cr>"; options.desc = "Audio (ffplay)"; }

    # ─────────────────────────────────────────────────────────────
    # Game
    # ─────────────────────────────────────────────────────────────
    { mode = "n"; key = "<leader>pG"; action = "<cmd>!godot --editor %:h/project.godot &<cr>"; options.desc = "Godot editor"; }
  ];
}
