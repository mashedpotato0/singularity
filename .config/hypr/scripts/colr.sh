#!/usr/bin/env bash

# move to script directory
cd "$(dirname "$0")" || exit 1

if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
fi

if command -v python3 >/dev/null 2>&1; then
    python3 color.py "$@"
else
    python color.py "$@"
fi
