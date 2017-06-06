#!/bin/bash
set -e

# Prototypes the use of SMACK toolchain (read: llvm2bpl)
# with a source Rust program.
#
# Expected to be run from within the context of the source file, e.g. ./smackrust.sh

# Assumes that SMACK has already been built.
# Assumes that Rust has been installed, and is on a version of LLVM
# that matches the SMACK LLVM version. As of initial checkin, 
# the "stable" version of "rustup" toolchain used LLVM 3.9.1
SOURCE_NAME="assignment"
MINIMAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUT_DIR="${MINIMAL_DIR}/out"


echo "Cleaning directories"
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"
cargo clean

# Build the Rust code, assuming that the lto option has been enabled for the dev profile
# in Cargo.toml
# Otherwise, would also add '-C lto' to the RUSTFLAGS
echo "Building Rust program to bitcode"
RUSTFLAGS='--emit=llvm-bc -A unused_variables -A unused_assignments' cargo build
SOURCE_NAME_PATTERN="${SOURCE_NAME}-*.bc"
COMPILED_BC="$(find ./target/debug/deps/ -name ${SOURCE_NAME_PATTERN} | xargs readlink -f)"
OUT_BC="${OUT_DIR}/${SOURCE_NAME}.bc"
cp "${COMPILED_BC}" "${OUT_BC}"

# Generate Boogie (BPL) file from LLVM Bitcode (BC)
echo "Generating Boogie file"
OUT_BPL="${OUT_DIR}/${SOURCE_NAME}.bpl"
../../build/llvm2bpl "${OUT_BC}" -bpl "${OUT_BPL}" -entry-points main 

# Note that the main entry point has been specified as a command argument
# rather than edited into the bpl file, as the Python script does
echo "Running Corral verifier"
corral "${OUT_BPL}" /tryCTrace /noTraceOnDisk /printDataValues:1 /k:1 /useProverEvaluate /timeLimit:1200 /cex:1 /maxStaticLoopBound:1 /recursionBound:1 /main:main
