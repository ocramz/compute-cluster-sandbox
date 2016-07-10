#!/bin/bash

# # NB : PETSc/SLEPc environment variables must be already set at this stage
# printenv | grep PETSC ..

# STACK_ARGS="$STACK_ARGS"
# PETSC_DIR="$PETSC_DIR"
# SLEPC_DIR="$SLEPC_DIR"
# PETSC_ARCH="$PETSC_ARCH"
# SLEPC_ARCH="$SLEPC_ARCH"

echo "== ENVIRONMENT :"
printenv

echo "=== ls -lsA"
ls -lsA

echo "=== pwd"
pwd


# retrieve latest source
echo "=== git clone petsc-hs"
git clone https://github.com/ocramz/petsc-hs.git

echo "=== cd petsc-hs"
cd petsc-hs


# echo "=== stack setup"
# stack setup


# generate and interpret c2hs script (architecture-dependent types)
echo "=== ./c2hs-build.sh"
./c2hs-build.sh ${PETSC_DIR} ${PETSC_ARCH} ${SLEPC_DIR} ${SLEPC_ARCH} ${PWD}/src/Numerical/PETSc/Internal/C2HsGen

echo "=== ./stack-build.sh"
./stack-build.sh "$STACK_ARGS" "$PETSC_DIR" "$PETSC_ARCH" "$SLEPC_DIR" "$SLEPC_ARCH"
