#!/usr/bin/env bash
rm -rf kernel
git clone $REPO -b $BRANCH kernel 
cd kernel
echo "Nuke previous toolchains"
rm -rf toolchain out AnyKernel
echo "cleaned up"
echo "Cloning dependencies"
git clone --depth=1 -b gcc https://github.com/malkist01/arm.git gcc32
git clone --depth=1 -b gcc https://github.com/malkist01/arm64.git gcc
echo "Done"
if [ "$is_test" = true ]; then
     echo "Its alpha test build"
     unset chat_id
     unset token
     export chat_id=${my_id}
     export token=${nToken}
else
     echo "Its beta release build"
fi
GCC="$(pwd)/gcc/bin/aarch64-linux-android-"
GCC32="$(pwd)/gcc32/bin/arm-linux-gnueabi-"
SHA=$(echo $DRONE_COMMIT_SHA | cut -c 1-8)
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +'%H%M-%d%m%y')
JOBS=$(nproc)
LOADS=$(nproc)
START=$(date +"%s")
KCF=-mno-android
DEF=teletubies_defconfig
export ARCH=arm64
export KBUILD_BUILD_USER=malkist
export KBUILD_BUILD_HOST=android
# sticker plox
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
        -d sticker="CAADBQADKwEAAkMQsyJtEJHSjxmH-wI" \
        -d chat_id=$chat_id
}
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>ChipsKernel CAF EAS</b> CI Triggered%0ABuild started on <code>Drone CI/CD</code>%0AFor device <b>Samsung</b> (J6PRIMELTE)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code> (Android 10-11)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b> #Nightly"
}
# Send private info
function sendpriv() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$priv_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="ChipsKernel CI Started%0ADrone triggered by: <code>${DRONE_BUILD_EVENT}</code> event%0AJob name: Chips%0ACommit point: <a href='${DRONE_COMMIT_LINK}'>$(git log --pretty=format:'"%h : %s"' -1)</a>%0A<b>Pipeline jobs</b> <a href='https://cloud.drone.io/najahiiii/kernel_asus_sdm660/${DRONE_BUILD_NUMBER}'>here</a>"
}
# Push kernel to channel
function push() {
    cd AnyKernel || exit 1
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>ASUS ZENFONE MAX PRO M1 (X00T/D)</b> | <b>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"
}
# Function upload logs to my own server paste
function paste() {
    cat build.log | curl -F 'chips=<-' https://chipslogs.herokuapp.com > link
    HASIL="$(cat link)"
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Job Baking Chips throw an error(s)"
    exit 1
}
# Compile plox
function compile() {
    make -s -C $(pwd) -j$JOBS O=out "${DEF}"
    make -C $(pwd) CROSS_COMPILE="${GCC}" CROSS_COMPILE_COMPAT="${GCC32}" KCFLAGS="${KCF}" O=out -j$JOBS -l$LOADS 2>&1| tee build.log
     if ! [ -a "$IMAGE" ]; then
        finderr
        exit 1
    fi

    git clone --depth=1 https://github.com/malkist01/anykernel3.git AnyKernel -b master
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
zipping() {
    cd AnyKernel || exit 1
    zip -r9 Teletubies"${CODENAME}"-"${DATE}".zip ./*
    cd ..
}
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push