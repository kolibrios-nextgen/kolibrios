#!/bin/bash

# Copyright (C) KolibriOS-NG team 2024. All rights reserved
# Distributed under terms of the GNU General Public License

set -eu

use_ver_gen=0
use_kerpack=0

lang="en"

show_help()
{
cat << EOF
Script for building the KolibriOS-NG kernel.
Usage: $0 [option]...

Arguments:
  -v            use "git describe" for generate "ver.inc"
  -l [lang]     use language, default "en"
  -p            pack kernels using the "kerpack" utility
  -c            clean build artifacts and exit
  -h            show this help and exit

Example:
  $0 -l ru -vp

EOF
}

while getopts "vl:pch" opt; do
  case "${opt}" in
    v) use_ver_gen=1 ;;
    l) lang=${OPTARG} ;;
    p) use_kerpack=1 ;;
    c)
      rm -f lang.inc ver.inc kernel.mnt kernel.mnt.ext_loader
      exit 0
      ;;
    h)
      show_help
      exit 0
      ;;
    *)
      echo "Bad arguments"
      exit 1
      ;;
  esac
done

if [ $use_ver_gen -eq 1 ]; then
  ./version-gen.sh > ver.inc
else
  cp -f ver_stub.inc ver.inc
fi

echo "lang fix $lang" > lang.inc

fasm -m 262144 kernel.asm kernel.mnt
fasm -m 262144 -dextended_primary_loader=1 kernel.asm kernel.mnt.ext_loader

if [ $use_kerpack -eq 1 ]; then
  kerpack kernel.mnt
  kerpack kernel.mnt.ext_loader
fi
