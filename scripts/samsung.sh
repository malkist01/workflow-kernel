#!/usr/bin/env bash
rm -rf kernel
git clone $REPO -b $BRANCH kernel 
cd kernel
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
echo "Clone Toolchains and AnyKernel"
git clone -j32 https://github.com/najahiiii/AnyKernel.git AnyKernel
git clone -j32 https://github.com/najahiiii/aarch64-linux-gnu.git -b gcc9-20190401 gcc
echo "Done"
GCC="$(pwd)/gcc/bin/aarch64-linux-gnu-"
tanggal=$(TZ=Asia/Jakarta date +'%H%M-%d%m%y')
START=$(date +"%s")
export ARCH=arm64
export KBUILD_BUILD_USER=Najahi
export KBUILD_BUILD_HOST=NusantaraDevs
# sticker plox
function sticker() {
        curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
                        -d sticker="CAADBQAD7wADQxCzIs_rqaRTwvagAg" \
                        -d chat_id=$chat_id
}
# Send info channel
function sendinfo() {
        curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
                        -d chat_id=$chat_id \
                        -d "disable_web_page_preview=true" \
                        -d "parse_mode=html" \
                        -d text="<b>ChipsKernel Google-Common</b> new build is up%0AStarted on <code>SemaphoreCI</code>%0AFor device <b>ROLEX</b> (Redmi 4A)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code> (Android 9.0/Pie)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>$(${GCC}gcc --version | head -n 1)</code>%0AStarted on <code>$(TZ=Asia/Jakarta date)</code>%0A<b>SemaphoreCI Status</b> <a href='https://ngntdkernel.semaphoreci.com/workflows/${SEMAPHORE_WORKFLOW_ID}'>here</a>%0A<b>Build Status:</b> #untested"
}
# Send private info
function sendpriv() {
        curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
                        -d chat_id=$priv_id \
                        -d "disable_web_page_preview=true" \
                        -d "parse_mode=html" \
                        -d text="ChipsKernel CI Started%0AJob Name: ${SEMAPHORE_JOB_NAME}%0ACommit point: <a href='https://github.com/najahiiii/moaikernal/commit/${SEMAPHORE_GIT_SHA}'>$(git log --pretty=format:'"%h : %s"' -1)</a>%0A<b>Pipeline jobs</b> <a href='https://ngntdkernel.semaphoreci.com/jobs/${SEMAPHORE_JOB_ID}'>here</a>"
}
# Push kernel to channel
function push() {
        cd AnyKernel
	ZIP=$(echo Chips*.zip)
	curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
			-F chat_id="$chat_id" \
			-F "disable_web_page_preview=true" \
			-F "parse_mode=html" \
			-F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | <b>Build logs</b> <a href='${HASIL}'>here</a> | #unified <b>GCC 9.1.1</b>"
}
# Function upload logs to my own server paste
function paste() {
        cat build.log | curl -F 'chips=<-' http://104.248.229.33:8181 > link
        HASIL="$(cat link)"
}
# Fin Error
function finerr() {
        paste
        curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
			-d chat_id="$chat_id" \
			-d "disable_web_page_preview=true" \
			-d "parse_mode=markdown" \
			-d text="Job ${SEMAPHORE_JOB_NAME} throw an error(s) | **Build logs** [here](${HASIL})"
        exit 1
}
# Compile plox
function compile() {
        make -s -C $(pwd) O=out teletubies_defconfig
        make -s -C $(pwd) CROSS_COMPILE=${GCC} O=out -j32 -l32 2>&1| tee build.log
            if ! [ -a $IMAGE ]; then
                finerr
                exit 1
            fi
        cp out/arch/arm64/boot/Image.gz-dtb AnyKernel/zImage
        paste
}
# Zipping
function zipping() {
        cd AnyKernel
        zip -r9 ChipsKernel-Pie-GCommon-${tanggal}.zip *
        cd ..
}
sendpriv
#sticker
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push

push
