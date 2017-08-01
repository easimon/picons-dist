#!/bin/bash

thisdir=$(dirname ${BASH_SOURCE[0]})

$thisdir/steps/checkout-pages.sh && $thisdir/steps/checkout-picons.sh