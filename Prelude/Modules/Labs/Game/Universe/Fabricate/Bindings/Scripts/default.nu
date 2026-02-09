#!/usr/bin/env nu

# Interpreter for Fabricate - export meshes for 3D printing
# Config: { action, input, output?, format?, layerHeight?, infill? }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)

  match $cfg.action {
    "export" => {
      let input: string = $cfg.input
      let format: string = ($cfg.format? | default "stl")
      let output: string = ($cfg.output? | default ([".lab/exports/model." $format] | str join ""))
      mkdir ($output | path dirname)
      ^blender --background $input --python-expr (["import bpy; bpy.ops.export_mesh." $format "(filepath='" $output "')"] | str join "")
      ["Exported:" $output] | str join " " | print
    }
    "slice" => {
      let input: string = $cfg.input
      let output: string = ($cfg.output? | default ".lab/exports/model.gcode")
      let layer: string = ($cfg.layerHeight? | default "0.2")
      let infill: string = ($cfg.infill? | default "20")
      mkdir ($output | path dirname)
      ^prusa-slicer --export-gcode --layer-height $layer --fill-density ([$infill "%"] | str join "") -o $output $input
      ["Sliced:" $output "layer:" $layer "infill:" $infill "%"] | str join " " | print
    }
  }
}
