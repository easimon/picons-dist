#!/bin/bash

set -euo pipefail

. vars.sh

echo "Copy PNGs"
cp picons-source/build-source/logos/*${iconset}.png $target/

echo "Converting SVGs"
for i in picons-source/build-source/logos/*${iconset}.svg; do
  svg=$i
  png=$target/$(basename "$i" ".svg").png
  echo "converting $svg"
  rsvg-convert --keep-aspect-ratio --width=1000 --format=png $svg | pngquant - > $png
done

echo "Renaming (removing iconset suffix)"
for i in target/*; do
  old=$i
  new=$(echo $old | sed "s/\.${iconset}\.png/.png/")
  mv $old $new
done

echo "Build complete"
