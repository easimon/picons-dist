#!/bin/bash

set -euo pipefail

pngquant="pngquant 256 -"

. vars.sh

echo "Quantize source PNGs"
for i in picons-source/build-source/logos/*${iconset}.png; do
  src=$i
  dst=$(basename $i)
  cat $i | $pngquant > $dst
  echo -n '.'
done

cp picons-source/build-source/logos/*${iconset}.png $target/

echo "Convert and quantize SVGs"
for i in picons-source/build-source/logos/*${iconset}.svg; do
  svg=$i
  png=$target/$(basename "$i" ".svg").png
  rsvg-convert --keep-aspect-ratio --width=1000 --format=png $svg | $pngquant > $png
  echo -n '.'
done

echo "Rename (remove iconset suffix)"
for i in $target/*.png; do
  old=$i
  new=$(echo $old | sed "s/\.${iconset}\.png/.png/")
  mv $old $new
  echo -n '.'
done

echo "Link channel names"
mkdir -p $target/snp
for i in $(cat picons-source/build-source/snp-index); do
  sid=$(echo $i | cut -f1 -d=)
  chn=$(echo $i | cut -f2 -d=)
  ln -s $target/$chn.png $target/snp/$sid.png
  echo -n '.'
done

echo "Link service names - not yet functional"
mkdir -p $target/srp
for i in $(cat picons-source/build-source/srp-index); do
  sid=$(echo $i | cut -f1 -d=)
  chn=$(echo $i | cut -f2 -d=)
  ln -s $target/$chn.png $target/srp/$sid.png
  echo -n '.'
done

echo "Build complete"
