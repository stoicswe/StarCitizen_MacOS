#!/usr/bin/env arch -x86_64 bash
set -e

##############################################
# Dependencies - Auto-install x86_64 Homebrew dependencies
##############################################

echo "Installing x86_64 Homebrew dependencies..."

# Check if x86_64 Homebrew is installed
if [[ ! -f "/usr/local/bin/brew" ]]; then
    echo "ERROR: x86_64 Homebrew not found at /usr/local/bin/brew"
    echo "Please install x86_64 Homebrew first:"
    echo "arch -x86_64 /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Install dependencies using x86_64 Homebrew
arch -x86_64 /usr/local/bin/brew install \
    freetype \
    fontconfig \
    jpeg \
    libpng \
    libtiff \
    little-cms2 \
    sdl2 \
    gettext \
    gnutls \
    libusb \
    molten-vk \
    mpg123 \
    libogg \
    libvorbis \
    flac \
    opus \
    bison \
    vulkan-loader \
    vulkan-headers \
    mingw-w64

echo "Dependencies installed successfully!"
echo "Continuing with Wine build..."

##############################################

export WINE_MAIN_VERSION="10.x" # 10.0, 9.x, 9.0, 8.x, 8.0
export ROOT=$(pwd)
export BUILDROOT=$ROOT/build/aarch64
export INSTALLROOT=$ROOT/install/aarch64
export SOURCESROOT=$ROOT/sources/aarch64
export JOB_COUNT=$(sysctl -n hw.logicalcpu)

export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH="/usr/local/opt/jpeg/lib/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH="/usr/local/opt/vulkan-loader/lib/pkgconfig:$PKG_CONFIG_PATH"
##############################################
# Versions
export WINE_VERSION="wine-10.15"
export WINE_MONO_VERSION="wine-mono-10.2.0"
export WINE_GECKO_VERSION="wine-gecko-2.47.4"
export WINESKIN_VERSION="WS12"
export WINE_CONFIGURE=$SOURCESROOT/$WINE_VERSION/configure

##############################################
# Some base bins
export BISON_PATH=/usr/local/opt/bison
export FREETYPE_PATH=/usr/local/opt/freetype
export PATH="$ROOT:$PATH"
export PATH="/usr/local/bin:$BISON_PATH/bin:$FREETYPE_PATH/bin:/usr/bin:/bin"
# Use our custom pkg-config wrapper for SDL2 compatibility
export PKG_CONFIG="$ROOT/pkg-config-wrapper.sh"
export OPTFLAGS="-g -O2"
# LDF Flags
export LDFLAGS="-L$BISON_PATH/lib"
export LDFLAGS="-L/usr/local/opt/jpeg/lib $LDFLAGS"
export LDFLAGS="-L/usr/local/opt/freetype/lib $LDFLAGS"
export LDFLAGS="-L/usr/local/opt/vulkan-loader/lib $LDFLAGS"
export LDFLAGS="-L/usr/local/opt/molten-vk/lib $LDFLAGS"
export LDFLAGS="-L/usr/local/opt/sdl2/lib $LDFLAGS"
# CPP Flags
export CPPFLAGS="-I/usr/local/opt/jpeg/include $CPPFLAGS"
export CPPFLAGS="-I/usr/local/opt/freetype/include/freetype2 $CPPFLAGS"
export CPPFLAGS="-I/usr/local/opt/vulkan-headers/include $CPPFLAGS"
export CPPFLAGS="-I/usr/local/opt/sdl2/include/SDL2 $CPPFLAGS"
# Other libs - use arch-specific pkg-config
export FREETYPE_CFLAGS="$(arch -x86_64 pkg-config --cflags freetype2)"
export FREETYPE_LIBS="$(arch -x86_64 pkg-config --libs freetype2)"
# SDL2 configuration - set environment variables for Wine's configure script
export SDL2_CFLAGS="-I/usr/local/opt/sdl2/include/SDL2"
export SDL2_LIBS="-L/usr/local/opt/sdl2/lib -lSDL2"
# Ensure SDL2 pkg-config works properly
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

##############################################
# Compiler versions
export WINE_CONFIGURE=$SOURCESROOT/$WINE_VERSION/configure
export CC="clang"
export CXX="clang++"
export i386_CC="/usr/local/bin/i686-w64-mingw32-gcc"
export x86_64_CC="/usr/local/bin/x86_64-w64-mingw32-gcc"

##############################################
# Library versions
export GSTREAMER_CFLAGS=$(/Library/Frameworks/GStreamer.framework/Commands/pkg-config --cflags gstreamer-1.0 gstreamer-video-1.0 gstreamer-audio-1.0 gstreamer-tag-1.0)
export GSTREAMER_LIBS=$(/Library/Frameworks/GStreamer.framework/Commands/pkg-config --libs gstreamer-1.0 gstreamer-video-1.0 gstreamer-audio-1.0 gstreamer-tag-1.0)
export FFMPEG_CFLAGS=$(/Library/Frameworks/GStreamer.framework/Commands/pkg-config --cflags libavutil libavformat libavcodec)
export FFMPEG_LIBS=$(/Library/Frameworks/GStreamer.framework/Commands/pkg-config --libs libavutil libavformat libavcodec)

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
    --build=x86_64-apple-darwin \
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
make install DESTDIR="$INSTALLROOT/$WINE_VERSION" -j$JOB_COUNT
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
