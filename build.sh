#!/bin/bash

set -euo pipefail

pngquant="pngquant 256 -"

. vars.sh

rm -rf $build
mkdir -p $build

echo "Copy source PNGs"
cp picons-source/build-source/logos/*.png $build

echo "Convert SVGs"
for i in picons-source/build-source/logos/*.svg; do
  svg=$i
  png=$build/$(basename "$i" ".svg").png
  rsvg-convert --format=png $svg > $png
  echo -n '.'
done
echo

echo "Resize and compose"
grep -v -e '^#' -e '^$' backgrounds.conf | while read lines; do
  currentlogo=""

  OLDIFS=$IFS
  IFS=";"
  line=($lines)
  IFS=$OLDIFS

  resolution=${line[0]}
  resize=${line[1]}
  type=${line[2]}
  background=${line[3]}

  dir=$target/$resolution/$type/$background
  echo "Build $dir"
  mkdir -p $dir

  for file in $(cat picons-source/build-source/snp-index); do
    sid=$(echo $file | cut -f1 -d=)
    chn=$(echo $file | cut -f2 -d=)
    dst=$dir/$sid.png
    src=$build/$chn.$type.png
    if [[ ! -f $src ]]; then
      src=$build/$chn.default.png
    fi
    
    bgfile=picons-source/build-source/backgrounds/$resolution/$background.png 
    convert $bgfile \( $src -background none -bordercolor none -border 100 -trim -border 1% -resize $resize -gravity center -extent $resolution +repage \) -layers merge - 2> /dev/null | $pngquant 2> /dev/null > $dst
    echo -n '.'
  done
  echo
done

#echo "Link service names - not yet functional"
#mkdir -p $target/srp
#for i in $(cat picons-source/build-source/srp-index); do
#  sid=$(echo $i | cut -f1 -d=)
#  chn=$(echo $i | cut -f2 -d=)
#  ln -s $target/$chn.png $target/srp/$sid.png
#  echo -n '.'
#done

echo "Build complete"
