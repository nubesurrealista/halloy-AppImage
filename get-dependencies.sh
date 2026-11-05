#!/bin/sh

set -eu

ARCH=$(uname -m)

# halloy only ships Linux binaries for x86_64
if [ "$ARCH" != "x86_64" ]; then
	echo "ERROR: halloy does not provide Linux binaries for $ARCH" >&2
	exit 1
fi

if [ "${DEVEL_RELEASE-}" = 1 ]; then
	VERSION=nightly
else
	VERSION=$(curl -sIL -o /dev/null -w '%{url_effective}' \
		"https://github.com/squidowl/halloy/releases/latest" | sed 's|.*/tag/||')
fi

if [ -z "$VERSION" ]; then
	echo "ERROR: Unable to determine the version of halloy" >&2
	exit 1
fi
echo "$VERSION" > ~/version

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
# winit dlopens these from the X11 backend, so they must be present here
# for quick-sharun to find and deploy them. alsa-lib and libxcb are not
# needed here, the setup action already installs them (pulseaudio-alsa and
# libx11) and quick-sharun aborts if a linked library is missing anyway.
pacman -Syu --noconfirm \
	libxcursor          \
	libxinerama         \
	libxkbcommon        \
	libxkbcommon-x11    \
	vulkan-icd-loader

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-mesa --prefer-nano

echo "Downloading halloy ${VERSION}..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 \
	"https://github.com/squidowl/halloy/releases/download/${VERSION}/halloy-${VERSION}-x86_64-linux.tar.gz" \
	-O ./halloy.tar.gz

mkdir -p ./halloy
tar -xvf ./halloy.tar.gz -C ./halloy
rm -f ./halloy.tar.gz
