#!/usr/bin/env bash

cd "$(dirname "$0")"

if [ ! -f ".venv/bin/activate" ]; then
    echo "Error: Virtual environment 'myenv' not found in $(pwd)"
    exit 1
fi

# Activate environment
source .venv/bin/activate

python gen.py

