#!/bin/bash

set -euo pipefail

. vars.sh

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

git clone --depth=1 --branch $target_branch $ssh_repo $target
cd $target
git config user.name  "Travis CI"
git config user.email "$GH_USER_EMAIL"
cd ..

echo "Clean target"
rm -fr $target/*
mkdir -p $target/srp

echo "Done"
