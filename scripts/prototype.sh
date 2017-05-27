#!/bin/bash

################################################################################
# Prototype for the product. Depends on `fzf`.
# Author: William Carroll
################################################################################

fzf <./index.txt | awk '{print $1}'
