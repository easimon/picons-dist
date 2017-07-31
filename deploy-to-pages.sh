#!/bin/bash

set -euo pipefail

. vars.sh

echo "Uploading to Github Pages"
sha=`git rev-parse --verify HEAD`

cd $target
git diff --quiet && git diff --staged --quiet || git commit -am "Deploy to Github Pages: ${sha}"
git push
cd ..

echo "Done"
