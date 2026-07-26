#!/bin/bash

PS7_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/ps7_init" && pwd )"
TARGET_DIR="$(dirname "$1")/board/xilinx/zynq"

mkdir -p "$TARGET_DIR"
cp "$PS7_DIR"/ps7_init_gpl.* "$TARGET_DIR/" 2>/dev/null || true

echo "[DNWT9002] ps7_init files copied"

