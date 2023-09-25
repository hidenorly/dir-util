#!/bin/bash
TARGET_DIR=$1
FILES=("$TARGET_DIR"/*)
for AFILE in "${FILES[@]}"
do
  echo "FILE: $AFILE"
done