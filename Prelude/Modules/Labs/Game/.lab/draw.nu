#!/usr/bin/env nu

# Draw script - edit this, save, and see live preview
def main [out: string = ".lab/renders/latest.png"]: nothing -> nothing {
  ^magick -size 128x128 xc:"#000000" -fill "#29ADFF" -draw "polygon 64,10 120,100 8,100" -fill "#FF77A8" -draw "circle 64,65 64,40" -fill "#FFEC27" -draw "polygon 64,45 80,70 48,70" -stroke "#00E436" -strokewidth 2 -fill none -draw "rectangle 20,105 108,120" -fill "#FFF1E8" -draw "point 55,58" -draw "point 73,58" $out
}
