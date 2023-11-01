#!/bin/sh

#参考文档
#https://developer.android.com/ndk/guides/other_build_systems?hl=zh-cn#autoconf


BUILD_DIR=$(pwd)/build
SOURCE_CODE_DIR=$BUILD_DIR/source

rm -rf $SOURCE_CODE_DIR
mkdir -p $SOURCE_CODE_DIR

#克隆代码到build目录下
git clone https://github.com/mstorsjo/fdk-aac $SOURCE_CODE_DIR

#源代码依赖了android的日志库这里会报错
#libSBRdec/src/lpp_tran.cpp:122:10: fatal error: 'log/log.h' file not found
#解决方案：https://github.com/mstorsjo/fdk-aac/issues/124
mkdir -p $SOURCE_CODE_DIR/libSBRdec/include/log/
echo "void android_errorWriteLog(int i, const char *string){}" \
  > $SOURCE_CODE_DIR/libSBRdec/include/log/log.h

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

function build_library {
  ABI=$1

  PREFIX_DIR=$(pwd)/../build
  mkdir -p $PREFIX_DIR

  cd $SOURCE_CODE_DIR

  autoreconf -fiv

  ./configure \
    --prefix=$PREFIX_DIR \
    --host=$TARGET \
    --bindir=$PREFIX_DIR/bin \
    --libdir=$PREFIX_DIR/libs/$ABI \
    --enable-shared=yes \
    --enable-static=yes

  #构建并安装
  make -j4 install
}

ABI_LIST=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

for abi in ${ABI_LIST[@]}; do
  echo $abi
  build_library $abi
done
