#!/bin/bash

CURL_VERSION=$1
ARCH="$2"
MIN_SDK_VERSION=29

case $ARCH in
    arm-linux-androideabi)
        OPENSSL_ARCH="android-arm"
        OUTPUT="armeabi-v7a"
        CLANG_PREFIX="armv7a-linux-androideabi$MIN_SDK_VERSION"
        ;;
    aarch64-linux-android)
        OPENSSL_ARCH="android-arm64"
        OUTPUT="arm64-v8a"
        CLANG_PREFIX="aarch64-linux-android$MIN_SDK_VERSION"
        ;;
    *)
        echo "Unsupported architecture provided: $ARCH"
        exit 1
        ;;
esac

export ANDROID_NDK_HOME=${HOME}/android-ndk-r21b
export PATH="${HOME}/android-ndk-r21b/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export TOOLCHAIN="${HOME}/android-ndk-r21b/toolchains/llvm/prebuilt/linux-x86_64"

export AR=$TOOLCHAIN/bin/${ARCH}-ar
export CC=$TOOLCHAIN/bin/${CLANG_PREFIX}-clang
export CXX=$TOOLCHAIN/bin/${CLANG_PREFIX}-clang++
export AS=$TOOLCHAIN/bin/${ARCH}-as
export LD=$TOOLCHAIN/bin/${ARCH}-ld
export RANLIB=$TOOLCHAIN/bin/${ARCH}-ranlib
export STRIP=$TOOLCHAIN/bin/${ARCH}-strip

SSL_PREFIX_DIR="${HOME}/output/android/openssl-${OPENSSL_ARCH}"

CURL_LIB_TAG="curl-$(echo $CURL_VERSION | sed 's/\./_/g')"
CURL_LIB_NAME="curl-$CURL_VERSION"
CURL_DOWNLOAD_URL="https://github.com/curl/curl/releases/download/${CURL_LIB_TAG}/${CURL_LIB_NAME}.tar.gz"

echo "download ${CURL_DOWNLOAD_URL}"

rm -rf "${LIB_DEST_DIR}" "${CURL_LIB_NAME}"
curl -LO ${CURL_DOWNLOAD_URL} >${CURL_LIB_NAME}.tar.gz

tar xfz ${CURL_LIB_NAME}.tar.gz
cd "${CURL_LIB_NAME}"

./configure --host=${ARCH} --enable-static --with-ssl=${SSL_PREFIX_DIR} --without-nghttp2
make -j4

mkdir -p ~/curl/lib/${OUTPUT}
find . -name libcurl.a -exec cp -- "{}" ~/curl/lib/${OUTPUT} \;
