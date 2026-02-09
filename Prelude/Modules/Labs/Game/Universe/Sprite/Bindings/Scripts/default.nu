#!/usr/bin/env nu

# Interpreter for Sprite - create, sheet, animate via imagemagick
# Config: { action, name, width, height, palette, frames, output? }
def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)

  match $cfg.action {
    "create" => {
      let w: int = ($cfg.width? | default 16)
      let h: int = ($cfg.height? | default 16)
      let out: string = ($cfg.output? | default ([$cfg.name ".png"] | str join ""))
      # Create sprite with checkerboard transparency pattern + colored border
      ^magick -size ([$w "x" $h] | str join "") xc:"#1D2B53" -fill "#FF004D" -draw (["rectangle 2,2 " ($w - 3 | into string) "," ($h - 3 | into string)] | str join "") -fill "#FFA300" -draw (["rectangle 4,4 " ($w - 5 | into string) "," ($h - 5 | into string)] | str join "") $out
      ["Created sprite:" $out ($w | into string) "x" ($h | into string)] | str join " " | print
    }
    "sheet" => {
      let frames: int = ($cfg.frames? | default 4)
      let w: int = ($cfg.width? | default 16)
      let h: int = ($cfg.height? | default 16)
      let out: string = ($cfg.output? | default ([$cfg.name "_sheet.png"] | str join ""))
      let tile: string = [($frames | into string) "x1"] | str join ""
      ^magick montage -geometry ([$w "x" $h "+0+0"] | str join "") -tile $tile ([$cfg.name "*.png"] | str join "") $out
      ["Created sheet:" $out $tile] | str join " " | print
    }
    "animate" => {
      let delay: int = ($cfg.delay? | default 10)
      let out: string = ($cfg.output? | default ([$cfg.name ".gif"] | str join ""))
      ^magick -delay ($delay | into string) -loop 0 ([$cfg.name "*.png"] | str join "") $out
      ["Created animation:" $out] | str join " " | print
    }
  }
}
