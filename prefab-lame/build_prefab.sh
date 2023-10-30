#!/bin/sh

#参考文档
#https://developer.android.com/ndk/guides/other_build_systems?hl=zh-cn#autoconf

LIB_NAME=lame
VERSION=3.100.0

ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

TARGET_BUILD_DIR=$(pwd)/lame-3.100/build

TARGET_ROOT_PREFAB_DIR=$(pwd)/build-prefab

rm -rf $TARGET_ROOT_PREFAB_DIR

TARGET_PREFAB_DIR=$TARGET_ROOT_PREFAB_DIR/prefab
mkdir -p $TARGET_PREFAB_DIR

#拷贝清单文件
MANIFEST_PATH=$(pwd)/AndroidManifest.xml

function copy_libs {
  TARGET_ABI=$1

  TARGET_ANDROID_ABI_DIR=$TARGET_PREFAB_DIR/modules/$LIB_NAME/libs/android.$TARGET_ABI
  mkdir -p $TARGET_ANDROID_ABI_DIR

  # 复制所有的.a以及.so文件
  cp -R $TARGET_BUILD_DIR/libs/$TARGET_ABI/* $TARGET_ANDROID_ABI_DIR/

  # 生成abi.json文件
  # 配置目录 prefab/modules/$libName/libs/android.$abi/abi.json
  pushd $TARGET_ANDROID_ABI_DIR
  echo "{
    \"abi\":\"$TARGET_ABI\",
    \"api\":21,
    \"ndk\":25,
    \"stl\":\"c++_shared\"
    }" >$TARGET_ANDROID_ABI_DIR/abi.json
  popd

}

# 进入prefab目录

pushd $TARGET_ROOT_PREFAB_DIR

mkdir -p $TARGET_PREFAB_DIR/modules/$LIB_NAME

# 生成prefab.json文件
# 配置目录 prefab/prefab.json
echo "{
    \"schema_version\": 1,
    \"name\": \"$LIB_NAME\",
    \"version\": \"$VERSION\",
    \"dependencies\": []
}" >$TARGET_PREFAB_DIR/prefab.json

echo $MANIFEST_PATH

# 复制清单文件
cp -R $MANIFEST_PATH $TARGET_ROOT_PREFAB_DIR/AndroidManifest.xml

# 复制头文件
cp -R $TARGET_BUILD_DIR/include $TARGET_PREFAB_DIR/modules/$LIB_NAME

# 生成module.json文件
# 配置目录 prefab/modules/$libName/module.json
pushd $TARGET_PREFAB_DIR/modules/$LIB_NAME
echo "{
    \"export_libraries\": [],
    \"library_name\": null,
    \"android\": {
      \"export_libraries\": [],
      \"library_name\": null
    }
}" >module.json
popd

for abi in ${ABIS[@]}; do
  copy_libs $abi
done

#删除冗余的文件
find . -name ".DS_Store" -delete

zip -r $LIB_NAME-$VERSION.aar . 2>/dev/null
zip -Tv $LIB_NAME-$VERSION.aar 2>/dev/null

# Verify that the aar contents are correct (see output below to verify)
result=$?
if [[ $result == 0 ]]; then
  echo "aar verified"
else
  echo "aar verification failed"
  exit 1
fi

mv $LIB_NAME-$VERSION.aar ..

popd
