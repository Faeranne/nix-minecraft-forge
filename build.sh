#!/bin/bash

version=$1
work_dir=$(mktemp -d)
build_dir=./build/

mkdir -p $build_dir

java -jar forge-$version-installer.jar --installServer $work_dir > /dev/null

nix-hash --sri --type sha256 $work_dir/libraries > build/result_hash

mv $work_dir/libraries $build_dir/libraries

rm -rf $work_dir

nix-store
