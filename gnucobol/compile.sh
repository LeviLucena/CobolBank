#!/bin/bash
# CobolBank - GnuCOBOL Compile Script
# Usage: ./compile.sh

set -e

PROJ_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJ_DIR"

echo "=== CobolBank GnuCOBOL Build ==="
echo "Directory: $PROJ_DIR"
echo ""

echo "[1/4] Compiling CBLAUTH (authentication module)..."
cobc -m CBLAUTH.cbl -o CBLAUTH.so
echo "      OK"

echo "[2/4] Compiling CBLTXN (transaction module)..."
cobc -m CBLTXN.cbl -o CBLTXN.so
echo "      OK"

echo "[3/4] Compiling SEED (demo data loader)..."
cobc -x SEED.cbl -o seed
echo "      OK"

echo "[4/4] Compiling CBLBANK (main program)..."
cobc -x CBLBANK.cbl -o cobolbank
echo "      OK"

echo ""
echo "=== Build complete ==="
echo ""
echo "Next steps:"
echo "  1. Load demo accounts : ./seed"
echo "  2. Run CobolBank      : ./cobolbank"
