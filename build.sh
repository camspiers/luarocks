#!/usr/bin/env sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

nvim -l "$SCRIPTPATH/lua/rocks/build.lua"
