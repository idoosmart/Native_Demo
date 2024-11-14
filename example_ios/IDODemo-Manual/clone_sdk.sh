#!/bin/bash

# gitee
# git_url_full="https://github.com/idoosmart/ios_sdk_full.git"
# git_url_lite="https://github.com/idoosmart/ios_sdk_lite.git"

# github
git_url_full="https://github.com/idoosmart/ios_sdk_full.git"
git_url_lite="https://github.com/idoosmart/ios_sdk_lite.git"

tmp_path=".tmp"
rm -rf ${tmp_path}
mkdir -p ${tmp_path}
pushd ${tmp_path} || exit 1

clone sdk
git clone -b main "${git_url_full}" IDOSDK-full --depth 1
clone_full_result=$?
if [ $clone_full_result -ne 0 ]; then
    echo "Cloning IDOSDK-full failed, please check your network"
    exit 1
fi

git clone -b main "${git_url_lite}" IDOSDK-lite --depth 1
clone_full_result=$?
if [ $clone_full_result -ne 0 ]; then
    echo "Cloning IDOSDK-lite failed, please check your network"
    exit 1
fi

if [ ! -d IDOSDK-full ] || [ ! -d IDOSDK-lite ]; then
  echo "clone failed, please check your network"
  exit 1
fi

# copy xcframework to IDODemo
rm -rf ../IDOSDK-full/ && mkdir -p ../IDOSDK-full
rm -rf ../IDOSDK-lite/ && mkdir -p ../IDOSDK-lite
cp -r IDOSDK-full/IDOSDK-full/libs/*.xcframework ../IDOSDK-full/
cp -r IDOSDK-lite/IDOSDK-lite/libs/*.xcframework ../IDOSDK-lite/
cp -r IDOSDK-full/IDOSDK-full/icon_assets.bundle ../IDOSDK-full/
cp -r IDOSDK-lite/IDOSDK-lite/icon_assets.bundle ../IDOSDK-lite/
echo "done"

popd || exit 1
rm -rf ${tmp_path}

exit 0