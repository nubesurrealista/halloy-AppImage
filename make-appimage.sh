#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=./halloy/share/icons/hicolor/512x512/apps/org.squidowl.halloy.png
export DESKTOP=./halloy/share/applications/org.squidowl.halloy.desktop
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
# the only datadir quick-sharun matches here is /usr/share/groff, because the
# string "groff" shows up in halloy's MIME type list, so skip datadir scanning
export DEPLOY_DATADIR=0

# Deploy dependencies
quick-sharun ./halloy/bin/halloy

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# The full test needs a GPU: halloy renders through wgpu and its GL fallback
# rejects the software renderer used in CI, so only check the AppImage starts
# and that its libraries are all in place
quick-sharun --simple-test ./dist/*.AppImage
