#!/bin/sh

#参考文档
#https://developer.android.com/ndk/guides/other_build_systems?hl=zh-cn#autoconf

BUILD_DIR=$(pwd)/build
SOURCE_CODE_DIR=$BUILD_DIR/lame-3.100

rm -rf $SOURCE_CODE_DIR
mkdir -p $SOURCE_CODE_DIR

#克隆代码到build目录下
git clone git@github.com:open-source-mirrors/lame.git -b 3.100 $SOURCE_CODE_DIR

cd $SOURCE_CODE_DIR

# 根据当前机器类型选择构建工具链
export TOOLCHAIN=$NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64
# export TOOLCHAIN=$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64

# 选择目标设备
export TARGET=aarch64-linux-android
# export TARGET=armv7a-linux-androideabi
# export TARGET=i686-linux-android
# export TARGET=x86_64-linux-android

# 设置最低的SDK版本
export API=21

#导出环境变量

export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

function build_lame {
  ABI=$1

  BUILD_DIR=$(pwd)/build/

  ./configure \
    --prefix=$BUILD_DIR \
    --host=$TARGET \
    --bindir=$BUILD_DIR/bin \
    --libdir=$BUILD_DIR/libs/$ABI \
    --enable-shared=yes \
    --enable-static=yes

  #构建并安装
  make -j4 install
}

ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

for abi in ${ABIS[@]}; do
  echo $abi
  build_lame $abi
done
