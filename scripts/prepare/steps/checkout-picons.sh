#!/bin/bash

set -euo pipefail

echo "Start Checkout picons-source"

thisdir=$(dirname ${BASH_SOURCE[0]})
. $thisdir/../../vars.sh

echo "Clone picons-source"
git clone --depth 1 https://github.com/picons/picons-source.git

