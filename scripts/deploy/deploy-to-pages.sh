#!/bin/bash

set -euo pipefail

thisdir=$(dirname ${BASH_SOURCE[0]})
. $thisdir/../vars.sh

echo "Upload to Github Pages"
sha=`git rev-parse --verify HEAD`

cd $target
git add .
git diff --quiet && git diff --staged --quiet || git commit -m "Deploy to Github Pages: ${sha}"
git push
cd ..

echo "Done"
