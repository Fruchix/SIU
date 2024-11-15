#!/bin/bash

git submodule update --init --recursive
# git submodule update --remote --merge

. utils/submodules/parse_yaml/src/parse_yaml.sh