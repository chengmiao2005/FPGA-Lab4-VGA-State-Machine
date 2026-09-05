#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--build-only" ) ]]; then
    echo "Usage: bash scripts/run_simulation.sh [--build-only]" >&2
    exit 2
fi
for tool in verilator make g++; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Missing required tool: $tool" >&2
        exit 127
    fi
done
mkdir -p "$repo_dir/build/obj_dir"
verilator -Wall -Wno-fatal --cc --exe --build \
    --top-module DevelopmentBoard --Mdir "$repo_dir/build/obj_dir" \
    -I"$repo_dir/rtl" \
    "$repo_dir/sim/DevelopmentBoard.v" "$repo_dir"/rtl/*.v \
    "$repo_dir/sim/simulator.cpp" \
    -CFLAGS "-std=c++17 -pthread" -LDFLAGS "-lglut -lGLU -lGL -pthread"
if [[ "${1:-}" != "--build-only" ]]; then
    exec "$repo_dir/build/obj_dir/VDevelopmentBoard"
fi
