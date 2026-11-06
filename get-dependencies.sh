#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	libxcursor          \
	libxinerama         \
	libxkbcommon        \
	libxkbcommon-x11    \
	vulkan-icd-loader

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-mesa --prefer-nano

echo "Downloading halloy..."
echo "---------------------------------------------------------------"
TARBALL_LINK=$(wget https://api.github.com/repos/squidowl/halloy/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -vi 'nightly' | grep -o -m 1 "https.*/halloy.*$ARCH-linux.tar.gz")
wget --retry-connrefused --tries=30 "$TARBALL_LINK" -O /tmp/tarball.tar.gz

mkdir -p ./AppDir
tar -xvf /tmp/tarball.tar.gz -C ./AppDir
cp -v ./AppDir/share/applications/org.squidowl.halloy.desktop           ./AppDir
cp -v ./AppDir/share/icons/hicolor/256x256/apps/org.squidowl.halloy.png ./AppDir

echo "$TARBALL_LINK" | awk -F'/' '{print $(NF-1)}' > ~/version
