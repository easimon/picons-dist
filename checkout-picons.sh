#!/bin/bash

set -euo pipefail

. vars.sh

echo "Cloning picons-source"
git clone --depth 1 https://github.com/picons/picons-source.git

