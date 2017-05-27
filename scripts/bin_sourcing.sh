#!/bin/bash

################################################################################
# Script used to source bins available in a user's $PATH.
# Author: William Carroll
################################################################################

echo "${PATH}" | xargs -d ':' ls -l 2>/dev/null | awk '{print $9}' | uniq >/tmp/source_bins.txt
