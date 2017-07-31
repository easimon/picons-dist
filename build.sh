#!/bin/bash

set -euo pipefail

iconset=default
target=target
target_branch=gh-pages

# Prepare SSH authentication
declare -r SSH_FILE="$(mktemp -u $HOME/.ssh/XXXXX)"

openssl aes-256-cbc \
 -K $encrypted_1030a5d78cc7_key \
 -iv $encrypted_1030a5d78cc7_iv \
 -in ".travis/github_deploy_key.enc" \
 -out "$SSH_FILE" -d

chmod 600 "$SSH_FILE" \
 && printf "%s\n" \
      "Host github.com" \
      "  IdentityFile $SSH_FILE" \
      "  LogLevel ERROR" >> ~/.ssh/config

# Check out gh-pages branch
echo "Cloning Github Pages branch"
repo=$(git config remote.origin.url)
ssh_repo=${repo/https:\/\/github.com\//git@github.com:}
sha=`git rev-parse --verify HEAD`

git clone $ssh_repo $target
cd $target
git config user.name  "Travis CI"
git config user.email "$GH_USER_EMAIL"
git checkout $target_branch
cd ..

echo "Clean target"
rm -fr $target/*

echo "Cloning picons-source"
git clone --depth 1 https://github.com/picons/picons-source.git

echo "Copy PNGs"
cp picons-source/build-source/logos/*${iconset}.png $target/

echo "Converting SVGs"
for i in picons-source/build-source/logos/*${iconset}.svg; do
  svg=$i
  png=$target/$(basename "$i" ".svg").png
  echo "converting $svg"
  rsvg-convert --keep-aspect-ratio --width=1000 --format=png --output=$png $svg
done

echo "Renaming (removing iconset suffix)"
for i in target/*; do
  old=$i
  new=$(echo $old | sed "s/\.${iconset}\.png/.png/")
  mv $old $new
done

echo "Build complete"

echo "Uploading to Github Pages"
cd $target
git add -A .
git commit -m "Deploy to Github Pages: ${sha}"
git push
cd ..

echo "Done"
