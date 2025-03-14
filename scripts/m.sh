#!/bin/bash
rm -rf kernel
git clone $REPO -b $BRANCH kernel 
cd kernel

git clone --depth=1 https://github.com/rokibhasansagar/linaro-toolchain-latest.git -b latest-4 gcc-64

export ARCH="arm64"
export CROSS_COMPILE="$(pwd)/gcc-64/bin/aarch64-linux-gnu-"
export PATH="$(pwd)/gcc-64/bin:$PATH"
export KBUILD_BUILD_USER="malkist"
export KBUILD_BUILD_HOST="android"
export USE_CCACHE=1
export CACHE_DIR=~/.ccache
curl -F chat_id="-1002287610863" -F text="Compiling New Commits..." https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendMessage
tanggal=$(date +'%m%d-%H%M')
rm -rf output
mkdir output
make -C $(pwd) O=output teletubies_defconfig
make -j8 -C $(pwd) O=output
if [ ! -f output/arch/arm64/boot/Image.gz-dtb ]; then
    echo "Teletubies, Compiling Failed"
    curl -F chat_id="-1002287610863" -F text="Teletubies, Compile Fail :(" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendMessage

else 
     if ! [ -a "$IMAGE" ]; then
        finderr
        exit 1
    fi

    git clone --depth=1 https://github.com/malkist01/anykernel3.git AnyKernel -b master
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel

# Zipping
zipping() {
    cd AnyKernel || exit 1
    zip -r9 Teletubies"${CODENAME}"-"${DATE}".zip ./*
    cd ..

echo "Yeehaa Booooi, Compiling Success!"
curl -F chat_id="-1002287610863" -F document=@"Teletubies-${tanggal}.zip" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendDocument
curl -F chat_id="-1002287610863" -F text="Teletubies, Compile Success :)" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendMessage

curl -F chat_id="-1002287610863" -F text="Whats New ?
$(git log --oneline --decorate --color --pretty=%s --first-parent -3)" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendMessage

curl -F chat_id="-1002287610863" -F sticker="CAADBQADZwADqZrmFoa87YicX2hwAg" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendSticker
