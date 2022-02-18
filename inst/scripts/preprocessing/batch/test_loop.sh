#!/usr/bin/env bash

# usage: test_loop.sh file_path output_dir

name=$(basename $1)

echo "Base file name in $1 is $name" > $2/$1
