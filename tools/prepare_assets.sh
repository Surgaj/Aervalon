#!/usr/bin/env bash
set -euo pipefail
# Mechanical chroma-key, atlas slicing and sizing; source art generated for Aervalon.
SRC="${1:?pass generated_images directory}"
OUT="assets/aervalon/v2"
mkdir -p "$OUT"
convert "$SRC/exec-a6b20b56-4372-482c-a65f-dc797dbc18e9.png" -alpha on -fuzz 35% -transparent '#ff00ff' /tmp/aervalon-props.png
names=(house forge tree market bridge supplies flowers well)
rects=(400x550+0+0 405x550+400+0 405x550+798+0 333x550+1203+0 515x460+0+560 310x460+515+560 390x460+825+560 321x460+1215+560)
for i in "${!names[@]}"; do convert /tmp/aervalon-props.png -crop "${rects[$i]}" +repage -trim +repage "$OUT/${names[$i]}.png"; done
convert "$SRC/exec-9bddd552-dd55-4f6d-a9df-7dfcac35ac1f.png" -alpha on -fuzz 35% -transparent '#ff00ff' -resize 2048x1024! "$OUT/hero.png"
convert "$SRC/exec-7530b7bd-26f5-4be4-a448-b4224a57e05c.png" -alpha on -fuzz 35% -transparent '#ff00ff' /tmp/aervalon-cast.png
# Source rows are intentionally measured rather than assuming perfect AI grid alignment.
convert /tmp/aervalon-cast.png -crop 1536x225+0+0 +repage -resize 1536x256! "$OUT/wolf_down.png"
convert /tmp/aervalon-cast.png -crop 1536x225+0+225 +repage -resize 1536x256! "$OUT/wolf_up.png"
for spec in 'mara 512x275+0+450' 'borin 768x290+512+430' 'eldric 256x290+1280+430' 'elder_walk 256x300+0+720' 'guard 512x310+256+710' 'hen 512x290+768+730' 'chest 256x290+1280+730'; do read -r name rect <<< "$spec"; convert /tmp/aervalon-cast.png -crop "$rect" +repage "$OUT/$name.png"; done
convert "$SRC/exec-38604d64-3aff-456d-a82b-9f3b10b09156.png" -resize 1024x1024! /tmp/aervalon-ground.png
names=(grass cobble water dirt)
for i in 0 1 2 3; do convert /tmp/aervalon-ground.png -crop "512x512+$((i%2*512))+$((i/2*512))" +repage "$OUT/${names[$i]}.png"; done
