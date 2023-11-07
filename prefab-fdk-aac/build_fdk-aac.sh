#!/bin/sh

#参考文档
#https://developer.android.com/ndk/guides/other_build_systems?hl=zh-cn#autoconf

CURRENT_DIR=$(pwd)

BUILD_DIR=$(pwd)/build
SOURCE_CODE_DIR=$BUILD_DIR/source

if [ "`ls -A $SOURCE_CODE_DIR`" = "" ]; then
    echo "$SOURCE_CODE_DIR is empty"
    rm -rf $SOURCE_CODE_DIR
    mkdir -p $SOURCE_CODE_DIR
    #克隆代码到build目录下
    git clone https://github.com/mstorsjo/fdk-aac $SOURCE_CODE_DIR
else
    echo "$SOURCE_CODE_DIR is not empty"
fi

#源代码依赖了android的日志库这里会报错
#libSBRdec/src/lpp_tran.cpp:122:10: fatal error: 'log/log.h' file not found
#解决方案：https://github.com/mstorsjo/fdk-aac/issues/124
mkdir -p $SOURCE_CODE_DIR/libSBRdec/include/log/
echo "void android_errorWriteLog(int i, const char *string){}" \
  > $SOURCE_CODE_DIR/libSBRdec/include/log/log.h

function build_library {
  ABI=$1
  HOST=$2

  echo "build library abi:${ABI} host:${HOST}"

  PREFIX_DIR=$CURRENT_DIR/../build/
  mkdir -p $PREFIX_DIR

  cd $SOURCE_CODE_DIR

  autoreconf -fiv

  ./configure \
    --prefix=$PREFIX_DIR \
    --host=$HOST \
    --bindir=$PREFIX_DIR/bin \
    --libdir=$PREFIX_DIR/libs/$ABI \
    --enable-shared=yes \
    --enable-static=yes

  #构建并安装
  make -j4 install
}

# 目前在M1的
ABI_LIST=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")
HOST_LIST=("aarch64-linux-android" "armv7a-linux-androideabi" "x86_64-linux-android" "i686-linux-android")

for((index=0;index<${#ABI_LIST[@]};index++));
do
    source $CURRENT_DIR/../setup-ndk-env.sh ${ABI_LIST[index]}
    build_library ${ABI_LIST[index]} ${HOST_LIST[index]}
    echo $index ${ABI_LIST[index]}
done

