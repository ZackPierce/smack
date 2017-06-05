#!/bin/bash
set -o xtrace
set -e

# A manual unrolling of the work the smack python runner does for a simple
# C program, applied to the corral verifier
# Expected to be run from within the context of the source file, e.g. ./manualsmack.sh

SMACK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../.. && pwd )"
MINIMAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUT_DIR="${MINIMAL_DIR}/out"

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

clang -c -emit-llvm -O0 -g -gcolumn-info -I"${SMACK_DIR}/share/smack/include" -DMEMORY_MODEL_NO_REUSE_IMPLS -o "${OUT_DIR}/minimal-CRiopm.bc" minimal.c

llvm-link -o "${OUT_DIR}/a-Mp_blc.bc" "${OUT_DIR}/minimal-CRiopm.bc"

clang -c -emit-llvm -O0 -g -gcolumn-info -I"${SMACK_DIR}/share/smack/include" -DMEMORY_MODEL_NO_REUSE_IMPLS -o "${OUT_DIR}/smack-_K215o.bc" "${SMACK_DIR}/share/smack/lib/smack.c"

llvm-link -o "${OUT_DIR}/b-jl79HC.bc" "${OUT_DIR}/a-Mp_blc.bc" "${OUT_DIR}/smack-_K215o.bc"

llvm2bpl "${OUT_DIR}/b-jl79HC.bc" -bpl "${OUT_DIR}/a-TTvSOF.bpl" -warnings -source-loc-syms -entry-points main -mem-mod-impls

# Note that the main entry point has been specified as a command argument
# rather than edited into the bpl file, as the Python script does
corral "${OUT_DIR}/a-TTvSOF.bpl" /tryCTrace /noTraceOnDisk /printDataValues:1 /k:1 /useProverEvaluate /timeLimit:1200 /cex:1 /maxStaticLoopBound:1 /recursionBound:1 /main:main
