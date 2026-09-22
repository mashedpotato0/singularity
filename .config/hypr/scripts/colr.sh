#!/usr/bin/env bash

# Move to script directory
cd "$(dirname "$0")" || exit
SCRIPT_DIR=$(pwd)

if [ ! -f ".venv/bin/activate" ]; then
    echo "Error: Virtual environment not found in $SCRIPT_DIR"
    exit 1
fi

source .venv/bin/activate
python color.py "$@"
