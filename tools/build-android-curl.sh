#!/bin/bash

CURL_VERSION=$1
SSL_VERSION=$2
ARCH="$3"
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
export ANDROID_NDK_HOME=~/android-ndk-r21b
export PATH="~/android-ndk-r21b/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

export AR=${ARCH}-ar
export CC=${CLANG_PREFIX}-clang
export CXX=${CLANG_PREFIX}-clang++
export AS=${ARCH}-as
export LD=${ARCH}-ld
export RANLIB=${ARCH}-ranlib
export STRIP=${ARCH}-strip

SSL_LIB_NAME="openssl-$SSL_VERSION"
SSL_DOWNLOAD_URL="https://www.openssl.org/source/${SSL_LIB_NAME}.tar.gz"

echo "download ${SSL_DOWNLOAD_URL}"

curl ${SSL_DOWNLOAD_URL} >${SSL_LIB_NAME}.tar.gz
tar xfz ${SSL_LIB_NAME}.tar.gz
cd "${SSL_LIB_NAME}"
SSL_PREFIX_DIR="${HOME}/output/android/openssl-${OPENSSL_ARCH}"
mkdir -p "${SSL_PREFIX_DIR}"
./Configure ${OPENSSL_ARCH} -D__ANDROID_API__=$MIN_SDK_VERSION --prefix="${SSL_PREFIX_DIR}"
make -j4
make install

CURL_LIB_TAG="curl-$(echo $CURL_VERSION | sed 's/\./_/g')"
CURL_LIB_NAME="curl-$CURL_VERSION"
CURL_DOWNLOAD_URL="https://github.com/curl/curl/releases/download/${CURL_LIB_TAG}/${CURL_LIB_NAME}.tar.gz"

echo "download ${CURL_DOWNLOAD_URL}"

rm -rf "${LIB_DEST_DIR}" "${CURL_LIB_NAME}"
curl -LO ${CURL_DOWNLOAD_URL} >${CURL_LIB_NAME}.tar.gz

tar xfz ${CURL_LIB_NAME}.tar.gz
cd "${CURL_LIB_NAME}"

./configure --target=${ARCH} --enable-static --with-ssl=${SSL_PREFIX_DIR} --without-nghttp2
make -j4

mkdir ~/curl/lib/${OUTPUT}
find . -name libcurl.a -exec cp -- "{}" ~/curl/lib/${OUTPUT} \;
