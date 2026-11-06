#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_OPENGL=1

# Deploy dependencies
quick-sharun ./AppDir/bin/*
rm -rf ./AppDir/share/groff

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# The full test needs a GPU: halloy renders through wgpu and its GL fallback
# rejects the software renderer used in CI, so only check the AppImage starts
# and that its libraries are all in place
quick-sharun --simple-test ./dist/*.AppImage
