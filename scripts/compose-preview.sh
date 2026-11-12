#!/usr/bin/env bash
# One preview format for every Velunori repository: the plugin's screenshot,
# unscaled where it fits, centred on the same 1280x720 backdrop with the same
# shadow. Usage: compose-preview.sh <screenshot.png> <docs/preview.png>
set -euo pipefail
[[ $# == 2 ]] || { echo "Usage: $0 <screenshot.png> <output.png>" >&2; exit 2; }
command -v magick >/dev/null || { echo 'Missing: magick (ImageMagick)' >&2; exit 1; }
source_image=$1
output=$2
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
# Screens taller than the frame are scaled down; nothing is ever enlarged.
magick "$source_image" -resize '1120x600>' "$work/sized.png"
# Screenshots of opaque windows carry square corners; round them like the panels.
read -r width height < <(magick identify -format '%w %h\n' "$work/sized.png")
magick -size "${width}x${height}" xc:black -fill white -draw "roundrectangle 0,0 $((width - 1)),$((height - 1)) 18,18" "$work/mask.png"
magick "$work/sized.png" "$work/mask.png" -alpha off -compose CopyOpacity -composite "$work/shot.png"
magick "$work/shot.png" \( +clone -background '#120818' -shadow 55x22+0+14 \) +swap -background none -layers merge +repage "$work/shadowed.png"
magick -size 1280x720 -define gradient:angle=160 gradient:'#6b3a6e-#e07a8a' \
  "$work/shadowed.png" -gravity center -composite -strip "$output"
echo "$output"
