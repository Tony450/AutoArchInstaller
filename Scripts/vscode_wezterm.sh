#!/bin/bash

target_dir="${1:-$PWD}"

if [ -d "$target_dir" ]; then
    wezterm start --cwd "$target_dir"
else
    wezterm start
fi