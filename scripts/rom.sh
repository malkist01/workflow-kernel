#!/usr/bin/env bash
rm -rf kernel
git clone $REPO -b $BRANCH kernel 
cd kernel
echo "Nuke previous toolchains"
rm -rf toolchain out AnyKernel
echo "cleaned up"
echo "Cloning dependencies"
git clone --depth=1 git clone https://github.com/Ramyski/Rom-Builder ROM
. Rom-Builder/Rom-Sync.sh
echo "Done"
