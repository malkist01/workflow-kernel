#!/bin/bash
rm -rf kernel
git clone $REPO -b $BRANCH kernel 
cd kernel

git clone --depth=1 https://github.com/rokibhasansagar/linaro-toolchain-latest.git -b latest-4 "$HOME"/gcc-64

export ARCH=arm64
export PATH="$HOME/gcc-64/bin:$PATH"
export CROSS_COMPILE=$HOME/gcc-64/aarch64-linux-gnu/bin/aarch64-linux-gnu-
export KBUILD_BUILD_USER=ProtoChuz
export KBUILD_BUILD_HOST=SemaphoreCI
export USE_CCACHE=1
export CACHE_DIR=~/.ccache
curl -F chat_id="-1002287610863" -F text="Compiling New Commits..." https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendMessage
tanggal=$(date +'%m%d-%H%M')
rm -rf output
mkdir output
make -C $(pwd) O=output teletubies_defconfig
make -j8 -C $(pwd) O=output
if [ ! -f output/arch/arm64/boot/Image.gz-dtb ]; then
    echo "HolyCrap, Compiling Failed"
    curl -F chat_id="-1002287610863" -F text="HolyCrap, Compile Fail :(" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendMessage

else 
cp output/arch/arm64/boot/Image.gz-dtb AnyKernel2/zImage
cd AnyKernel2
rm -rf *.zip
zip -r9 CrappyKernel-Liquor-${tanggal}.zip * -x README.md CrappyKernel-Liquor--${tanggal}.zip
echo "Yeehaa Booooi, Compiling Success!"
curl -F chat_id="-1002287610863" -F document=@"CrappyKernel-Liquor-${tanggal}.zip" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendDocument
curl -F chat_id="-1002287610863" -F text="HolyCrap, Compile Success :)" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendMessage
curl -F chat_id="-1002287610863" -F text="Whats New ?
$(git log --oneline --decorate --color --pretty=%s --first-parent -3)" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendMessage

fi
curl -F chat_id="-1002287610863" -F sticker="CAADBQADZwADqZrmFoa87YicX2hwAg" https://api.telegram.org/bot7596553794:AAGoeg4VypmUfBqfUML5VWt5mjivN5-3ah8/sendSticker
