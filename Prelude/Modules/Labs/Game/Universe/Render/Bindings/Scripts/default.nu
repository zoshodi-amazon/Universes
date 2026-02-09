#!/usr/bin/env nu

# Interpreter for Render - 2D (imagemagick) and 3D (blender headless)
# Config: { action, input?, output?, dimension?, resolution?, scale? }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)

  match $cfg.action {
    "render-2d" => {
      let input: string = $cfg.input
      let output: string = ($cfg.output? | default ".lab/renders/latest.png")
      let res: string = ($cfg.resolution? | default "320x240")
      mkdir ($output | path dirname)
      ^magick $input -resize $res -filter Point $output
      ["Rendered 2D:" $output $res] | str join " " | print
    }
    "render-3d" => {
      let script: string = $cfg.input
      let output: string = ($cfg.output? | default ".lab/renders/latest.png")
      let res: string = ($cfg.resolution? | default "1920x1080")
      let parts: list<string> = ($res | split row "x")
      mkdir ($output | path dirname)
      ^blender --background --python $script -- --render-output $output --render-format PNG -x ($parts | get 0) -y ($parts | get 1) --render-frame 1
      ["Rendered 3D:" $output] | str join " " | print
    }
    "pixel-scale" => {
      let input: string = $cfg.input
      let output: string = $cfg.output
      let scale: string = ($cfg.scale? | default "400%")
      ^magick $input -filter Point -resize $scale $output
      ["Scaled:" $output $scale] | str join " " | print
    }
  }
}
