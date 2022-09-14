#!/bin/bash

SSL_VERSION=$1
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

cd ~
wget -O NDK -q https://dl.google.com/android/repository/android-ndk-r21b-linux-x86_64.zip
sudo apt install unzip -y
unzip -q NDK
cd -
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

SSL_LIB_NAME="openssl-$SSL_VERSION"
SSL_DOWNLOAD_URL="https://www.openssl.org/source/${SSL_LIB_NAME}.tar.gz"

echo "download ${SSL_DOWNLOAD_URL}"

curl ${SSL_DOWNLOAD_URL} >${SSL_LIB_NAME}.tar.gz
tar xfz ${SSL_LIB_NAME}.tar.gz
cd "${SSL_LIB_NAME}"
SSL_PREFIX_DIR="${HOME}/output/android/openssl-${OPENSSL_ARCH}"
mkdir -p "${SSL_PREFIX_DIR}"
./Configure ${OPENSSL_ARCH} no-shared -D__ANDROID_API__=$MIN_SDK_VERSION --prefix="${SSL_PREFIX_DIR}"
make -j4
make install
