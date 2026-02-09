#!/bin/bash
# Draw script - edit this, save, and see live preview
# Output path is passed as $1
OUT="${1:-.lab/renders/latest.png}"

# 64x64 sprite with PICO-8 palette
magick -size 64x64 xc:"#1D2B53" \
  -fill "#FF004D" -draw "rectangle 8,8 55,55" \
  -fill "#FFA300" -draw "rectangle 16,16 47,47" \
  -fill "#FFEC27" -draw "circle 32,32 32,24" \
  -fill "#00E436" -draw "rectangle 28,28 35,35" \
  "$OUT"
