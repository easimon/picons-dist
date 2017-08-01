#!/bin/bash

set -euo pipefail

pngquant="pngquant 256 -"

thisdir=$(dirname ${BASH_SOURCE[0]})
. $thisdir/../vars.sh

rm -rf $build
mkdir -p $build

echo "Copy source PNGs"
cp picons-source/build-source/logos/*.png $build

echo "Convert SVGs"
for i in picons-source/build-source/logos/*.svg; do
  svg=$i
  png=$build/$(basename "$i" ".svg").png
  rsvg-convert --format=png --keep-aspect-ratio --width=1000 $svg > $png
  echo -n '.'
done
echo

echo "Size of $build: $(du -sh $build | cut -f1)"

exit 0

echo "Resize and compose"
grep -v -e '^#' -e '^$' backgrounds.conf | while read lines; do

  OLDIFS=$IFS
  IFS=";"
  line=($lines)
  IFS=$OLDIFS

  resolution=${line[0]}
  resize=${line[1]}
  type=${line[2]}
  background=${line[3]}
  bgfile=picons-source/build-source/backgrounds/$resolution/$background.png
  dir=$target/$resolution/$type/$background
  echo "Resize and compose $resolution/$type/$background"
  mkdir -p $dir
  for file in $(cat picons-source/build-source/snp-index); do
    sid=$(echo $file | cut -f1 -d=)
    chn=$(echo $file | cut -f2 -d=)
    dst=$dir/$chn.png
    src=$build/$chn.$type.png
    if [[ ! -f $src ]]; then
      src=$build/$chn.default.png
    fi

    if [[ ! -f $dst ]]; then
#      cp $src $dst
#      convert $bgfile \( $src -background none -bordercolor none -border 100 -trim -border 1% -resize $resize -gravity center -extent $resolution +repage \) -layers merge - | $pngquant > $dst
      convert $bgfile \( $src -background none -bordercolor none -border 100 -trim -border 1% -resize $resize -gravity center -extent $resolution +repage \) -layers merge - > $dst
    fi

    if [[ $chn.png != $sid.png ]]; then
      dstlink=$dir/$sid.png
      rm -f $dstlink
      ln -s $chn.png $dstlink
    fi
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
