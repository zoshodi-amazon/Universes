#!/usr/bin/env nu

# Interpreter for Simulate - physics via blender headless
# Config: { action, scene, frames?, timeStep?, gravity?, output?, frame? }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)

  match $cfg.action {
    "run" => {
      let scene: string = $cfg.scene
      let frames: int = ($cfg.frames? | default 60)
      let output: string = ($cfg.output? | default ".lab/renders/sim_")
      mkdir ($output | path dirname)
      ^blender --background $scene --python-expr (["import bpy; bpy.ops.ptcache.bake_all(bake=True); bpy.context.scene.frame_end =" ($frames | into string) "; bpy.context.scene.render.filepath = '" $output "'; bpy.ops.render.render(animation=True)"] | str join " ")
      ["Simulated:" ($frames | into string) "frames ->" $output] | str join " " | print
    }
    "render-frame" => {
      let scene: string = $cfg.scene
      let frame: int = ($cfg.frame? | default 1)
      let output: string = ($cfg.output? | default ".lab/renders/frame.png")
      mkdir ($output | path dirname)
      ^blender --background $scene --render-output $output --render-format PNG --render-frame ($frame | into string)
      ["Rendered frame" ($frame | into string) "->" $output] | str join " " | print
    }
  }
}
