#!/usr/bin/env bash
set -e

##############################################
# Dependancies
brew install freetype fontconfig jpeg libpng libtiff little-cms2 \
             sdl2 gettext gnutls libusb molten-vk mpg123 \
             libogg libvorbis flac opus
##############################################

export WINE_MAIN_VERSION="10.x" # 10.0, 9.x, 9.0, 8.x, 8.0
export WINE_CONFIGURE=~/Github/wine/configure
export ROOT=$(pwd)
export BUILDROOT=$ROOT/build/arm64
export INSTALLROOT=$ROOT/install/arm64
export SOURCESROOT=$ROOT/sources/arm64
export JOB_COUNT=$(sysctl -n hw.logicalcpu)

export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH="/opt/homebrew/opt/jpeg/lib/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH="$(brew --prefix vulkan-loader)/lib/pkgconfig:$PKG_CONFIG_PATH"
##############################################
# Versions
export WINE_VERSION="wine-10.15"
export WINE_MONO_VERSION="wine-mono-10.2.0"
export WINE_GECKO_VERSION="wine-gecko-2.47.4"
export WINESKIN_VERSION="WS12"
export WINE_CONFIGURE=$SOURCESROOT/$WINE_VERSION/configure

##############################################
# Some base bins - ARM64 native
export BISON_PATH=$(brew --prefix bison)
export FREETYPE_PATH=$(brew --prefix freetype)
export PATH="$BISON_PATH/bin:$FREETYPE_PATH/bin:$(brew --prefix)/bin:/usr/bin:/bin"
export OPTFLAGS="-g -O2"
# LDF Flags
export LDFLAGS="-L$BISON_PATH/lib"
export LDFLAGS="-L$(brew --prefix jpeg)/lib $LDFLAGS"
export LDFLAGS="-L$(brew --prefix freetype)/lib $LDFLAGS"
export LDFLAGS="-L$(brew --prefix vulkan-loader)/lib $LDFLAGS"
export LDFLAGS="-L$(brew --prefix molten-vk)/lib $LDFLAGS"
# CPP Flags
export CPPFLAGS="-I$(brew --prefix jpeg)/include $CPPFLAGS"
export CPPFLAGS="-I$(brew --prefix freetype)/include/freetype2 $CPPFLAGS"
export CPPFLAGS="-I$(brew --prefix vulkan-headers)/include $CPPFLAGS"
# Other libs
export FREETYPE_CFLAGS="$(pkg-config --cflags freetype2)"
export FREETYPE_LIBS="$(pkg-config --libs freetype2)"

##############################################
# Compiler versions - ARM64 native
export WINE_CONFIGURE=$SOURCESROOT/$WINE_VERSION/configure
export CC="ccache clang"
export CXX="ccache clang++"
# Note: Remove mingw cross-compilers for ARM64 build or install ARM64 versions

##############################################
# Library versions
export GSTREAMER_CFLAGS=$(/Library/Frameworks/GStreamer.framework/Commands/pkg-config --cflags gstreamer-1.0 gstreamer-video-1.0 gstreamer-audio-1.0 gstreamer-tag-1.0)
export GSTREAMER_LIBS=$(/Library/Frameworks/GStreamer.framework/Commands/pkg-config --libs gstreamer-1.0 gstreamer-video-1.0 gstreamer-audio-1.0 gstreamer-tag-1.0)
export FFMPEG_CFLAGS=$(/Library/Frameworks/GStreamer.framework/Commands/pkg-config --cflags libavutil libavformat libavcodec)
export FFMPEG_LIBS=$(/Library/Frameworks/GStreamer.framework/Commands/pkg-config --libs libavutil libavformat libavcodec)

# Rest of the script would be the same...
##############################################
# Download wine source
echo "Download sources: wine"
export WINE_SOURCE_URL="https://dl.winehq.org/wine/source/$WINE_MAIN_VERSION/$WINE_VERSION.tar.xz"

if [[ ! -f $WINE_VERSION.tar.xz ]]; then
    echo "Download $WINE_VERSION.tar.xz"
    curl -o $WINE_VERSION.tar.xz $WINE_SOURCE_URL
fi

echo "Download binaries: wine-mono, wine-gecko"

export WINE_MONO_BINARY_x86_URL="https://dl.winehq.org/wine/wine-mono/${WINE_MONO_VERSION#wine-mono-}/$WINE_MONO_VERSION-x86.tar.xz"
export WINE_GECKO_BINARY_x86_URL="https://dl.winehq.org/wine/wine-gecko/${WINE_GECKO_VERSION#wine-gecko-}/$WINE_GECKO_VERSION-x86.tar.xz"
export WINE_GECKO_BINARY_x86_64_URL="https://dl.winehq.org/wine/wine-gecko/${WINE_GECKO_VERSION#wine-gecko-}/$WINE_GECKO_VERSION-x86_64.tar.xz"

if [[ ! -f $WINE_MONO_VERSION-x86.tar.xz ]]; then
    echo "Download $WINE_MONO_VERSION-x86.tar.xz"
    curl -o $WINE_MONO_VERSION-x86.tar.xz $WINE_MONO_BINARY_x86_URL
fi

if [[ ! -f $WINE_GECKO_VERSION-x86.tar.xz ]]; then
    echo "Download $WINE_GECKO_VERSION-x86.tar.xz"
    curl -o $WINE_GECKO_VERSION-x86.tar.xz $WINE_GECKO_BINARY_x86_URL
fi

if [[ ! -f $WINE_GECKO_VERSION-x86_64.tar.xz ]]; then
    echo "Download $WINE_GECKO_VERSION-x86_64.tar.xz"
    curl -o $WINE_GECKO_VERSION-x86_64.tar.xz $WINE_GECKO_BINARY_x86_64_URL
fi

mkdir -p $SOURCESROOT

if [[ -d "$SOURCESROOT/$WINE_VERSION" ]]; then
    rm -rf $SOURCESROOT/$WINE_VERSION
fi

echo "Extract $WINE_VERSION"
pushd $SOURCESROOT
tar xf $ROOT/$WINE_VERSION.tar.xz
popd

pushd $SOURCESROOT/$WINE_VERSION
#echo "$ROOT/wine-patches/0001"
#patch -p1 --no-backup < $ROOT/wine-patches/0001-winemac.drv-no-flicker.patch
#echo "$ROOT/wine-patches/0002"
#patch -p1 --no-backup < $ROOT/wine-patches/0002-macos-hacks.patch
echo "$ROOT/wine-patches/0003"
patch -p1 --no-backup < $ROOT/wine-patches/0003-wined3d-moltenvk-hacks.patch
#echo "$ROOT/wine-patches/0004"
#patch -p1 --no-backup < $ROOT/wine-patches/0004-opengl-macos-hacks.patch
#echo "$ROOT/wine-patches/0005"
#patch -p1 --no-backup < $ROOT/wine-patches/0005-add-msync.patch
echo "$ROOT/wine-patches/0006"
patch -p1 --no-backup < $ROOT/wine-patches/0006-10.2+_eac_fix.patch
echo "$ROOT/wine-patches/0007"
patch -p1 --no-backup < $ROOT/wine-patches/0007-eac_60101_timeout.patch
popd

if [[ -d "$BUILDROOT" ]]; then
    rm -rf "$BUILDROOT"
fi

echo "Configure $WINE_VERSION"
mkdir -p $BUILDROOT/$WINE_VERSION
pushd $BUILDROOT/$WINE_VERSION
#    --with-gnutls \
#     --with-opengl \
#     --with-freetype \
$WINE_CONFIGURE \
    --prefix= \
    --disable-tests \
    --enable-win64 \
    --enable-archs=i386,x86_64 \
    --without-alsa \
    --without-capi \
    --with-coreaudio \
    --with-cups \
    --without-dbus \
    --without-fontconfig \
    --with-freetype \
    --with-gettext \
    --without-gettextpo \
    --without-gphoto \
    --without-gssapi \
    --with-gstreamer \
    --without-inotify \
    --without-krb5 \
    --with-mingw \
    --without-netapi \
    --with-opencl \
    --without-oss \
    --with-pcap \
    --with-pcsclite \
    --with-pthread \
    --without-pulse \
    --without-sane \
    --with-sdl \
    --without-udev \
    --with-unwind \
    --without-usb \
    --without-v4l2 \
    --with-vulkan \
    --without-wayland \
    --without-x
popd

echo "Build $WINE_VERSION"
pushd $BUILDROOT/$WINE_VERSION
make -j$JOB_COUNT
popd

if [[ -d "$INSTALLROOT" ]]; then
    rm -rf $INSTALLROOT
fi

echo "Install $WINE_VERSION"
pushd $BUILDROOT/$WINE_VERSION
make install-lib DESTDIR="$INSTALLROOT/$WINE_VERSION" -j$JOB_COUNT
popd

echo "Extract $WINE_MONO_VERSION"
mkdir -p $INSTALLROOT/$WINE_VERSION/share/wine/mono
pushd $INSTALLROOT/$WINE_VERSION/share/wine/mono
tar xf $ROOT/$WINE_MONO_VERSION-x86.tar.xz
popd

echo "Extract $WINE_GECKO_VERSION"
mkdir -p $INSTALLROOT/$WINE_VERSION/share/wine/gecko
pushd $INSTALLROOT/$WINE_VERSION/share/wine/gecko
tar xf $ROOT/$WINE_GECKO_VERSION-x86.tar.xz
tar xf $ROOT/$WINE_GECKO_VERSION-x86_64.tar.xz
popd
