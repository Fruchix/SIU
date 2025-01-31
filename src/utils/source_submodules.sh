#!/usr/bin/env bash

git submodule update --init --recursive
# git submodule update --remote --merge

. src/utils/submodules/parse_yaml/src/parse_yaml.sh