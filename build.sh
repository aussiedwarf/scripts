#!/bin/sh
AD_OS=macos
AD_ARCH=x64
AD_COMPILER=clang
AD_PROFILE=release
AD_DIR=~/dev/thirdparty
AD_SDL2=$AD_DIR/SDL/SDL2-2.0.5
AD_SDL2_IMAGE=$AD_DIR/SDL/SDL2_image-2.0.1
AD_SDL2_TTF=$AD_DIR/SDL/SDL2_ttf-2.0.14
AD_SDL2_NET=$AD_DIR/SDL/SDL2_net-2.0.1
AD_ZLIB=$AD_DIR/zlib/zlib-1.2.11
AD_LIBPNG=$AD_DIR/libpng/libpng-1.6.29
AD_LIBJPG=$AD_DIR/libjpeg/jpeg-9b                    
#AD_JBIGKIT=$AD_DIR/
AD_XZ=$AD_DIR/xz/xz-5.2.3
AD_LIBTIF=$AD_DIR/libtiff/tiff-4.0.8
AD_LIBWEBP=$AD_DIR/libwebp/libwebp-0.6.0
AD_LIBGIF=$AD_DIR/giflib/giflib-5.1.4
AD_FREETYPE=$AD_DIR/freetype/freetype-2.8
AD_BZIP=$AD_DIR/bzip2/bzip2-1.0.6
AD_HARFBUZZ=$AD_DIR/harfbuzz/harfbuzz-1.4.6

USE_GPL=false

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPDIR="${BASEDIR}/temp"


echo "Running script from $BASEDIR"
echo "Currently in $TEMPDIR"


while [ "$1" != "" ]; do
    case $1 in
        -d | --directory )      shift
                                AD_DIR=$1
                                ;;
        -o | --os )             shift
                                AD_OS=$1
                                ;;
        -a | --arch )           shift
                                AD_ARCH=$1
                                ;;
        -c | --compiler )       shift
                                AD_COMPILER=$1
                                ;;
        -p | --profile )        shift
                                AD_PROFILE=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

Usage ()
{
    echo "Usage: [[[-f file ] [-i]] | [-h]] "
}



#http://blog.httrack.com/blog/2014/03/09/what-are-your-gcc-flags/
AD_CFLAGS="-D_FILE_OFFSET_BITS=64 -Wall -O3 -fomit-frame-pointer -funroll-loops -mfpmath=sse -msse -msse2 -msse3 -mssse3"
# -msse4.1 -msse4.2 -msse4
# -frename-registers not for clang

if [ "$AD_COMPILER" = "gcc" ]
then
    AD_CFLAGS="$AD_CFLAGS -frename-registers"
fi

echo "CFLAGS: $AD_CFLAGS"


AD_EXEC=$AD_OS/$AD_ARCH/$AD_COMPILER/$AD_PROFILE
echo "Build dir: $AD_EXEC"


echo "Thirdparty directory: $AD_DIR"

if false
then


#zlib license
#https://zlib.net/
echo "Building zlib"
rm -rf temp
mkdir temp
cd temp
$AD_ZLIB/./configure --static --prefix=$AD_ZLIB/build --eprefix=$AD_ZLIB/build/$AD_EXEC
make clean
make CFLAGS="$AD_CFLAGS"
make install
cd $BASEDIR



#libPNG license (permissive)
#http://www.libpng.org/pub/png/libpng.html
echo "Building libpng"
rm -rf temp
mkdir temp
cd temp
LIBPNG_CFLAGS="$AD_CFLAGS -I$AD_ZLIB/build/include"
echo "LIBPNG FLAGS $LIBPNG_CFLAGS"
$AD_LIBPNG/./configure CFLAGS="$AD_CFLAGS" --enable-intel-sse --disable-shared --enable-static LDFLAGS=-L$AD_ZLIB/build/$AD_EXEC/lib --prefix=$AD_LIBPNG/build --exec-prefix=$AD_LIBPNG/build/$AD_EXEC CPPFLAGS="-I$AD_ZLIB/build/include"
make clean
make
make install
cd $BASEDIR



#IJG libjpg
#Wikipedia says BSD like
#http://www.ijg.org/
#https://sourceforge.net/projects/libjpeg/
echo "Building libjpeg"
rm -rf temp
mkdir temp
cd temp
$AD_LIBJPG/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix=$AD_LIBJPG/build --exec-prefix=$AD_LIBJPG/build/$AD_EXEC
make clean
make
make install
cd $BASEDIR



#LZMA
#public domain
#https://tukaani.org/xz/
echo "Building xz"
rm -rf temp
mkdir temp
cd temp
$AD_XZ/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix=$AD_XZ/build --exec-prefix=$AD_XZ/build/$AD_EXEC
make clean
make
make install
cd $BASEDIR



#permissive
#http://www.simplesystems.org/libtiff/
echo "Building libtiff"
rm -rf temp
mkdir temp
cd temp
$AD_LIBTIF/./configure CFLAGS="$AD_CFLAGS" --disable-shared --with-zlib-include-dir=$AD_ZLIB/build/include --with-zlib-lib-dir=$AD_ZLIB/build/$AD_EXEC/lib --with-jpeg-include-dir=$AD_LIBJPG/build/include --with-jpeg-lib-dir=$AD_LIBJPG/build/$AD_EXEC/lib --with-lzma-include-dir=$AD_XZ/build/include --with-lzma-lib-dir=$AD_XZ/build/$AD_EXEC/lib  --prefix=$AD_LIBTIF/build --exec-prefix=$AD_LIBTIF/build/$AD_EXEC


#--with-jbig-include-dir=DIR location of JBIG-KIT headers which are GPL
#--with-jbig-lib-dir=DIR location of JBIG-KIT library binary
#unsure of source for libjpeg12
#looks to be ijg compiled again for 12bit but may need modifiedtiff and jpeg code to not clash
#don't need 12bit support
#--with-jpeg12-include-dir=DIR location of libjpeg 12bit headers
#--with-jpeg12-lib=LIBRARY path to libjpeg 12bit library

make clean
make
make install
cd $BASEDIR



#permissive
#http://giflib.sourceforge.net/
echo "Building giflib"
rm -rf temp
mkdir temp
cd temp
$AD_LIBGIF/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix=$AD_LIBGIF/build --exec-prefix=$AD_LIBGIF/build/$AD_EXEC
make clean
make
make install
cd $BASEDIR



#permissive
#http://www.bzip.org/
echo "Building bzip2"
cd $AD_BZIP
make clean
make CFLAGS="$AD_CFLAGS"
make install -f $AD_BZIP/Makefile  PREFIX=$AD_BZIP/build/$AD_EXEC
cd $BASEDIR



#permissive
#
echo "Building SDL2"
rm -rf temp
mkdir temp
cd temp
$AD_SDL2/./configure CFLAGS="$AD_CFLAGS" --enable-sse2 --disable-shared --enable-static --prefix=$AD_SDL2/build --exec-prefix=$AD_SDL2/build/$AD_EXEC
#ALSA or esd may be needed on linux for sound
#--with-alsa-prefix=PFX  Prefix where Alsa library is installed(optional)
#--with-alsa-inc-prefix=PFX  Prefix where include libraries are (optional)
#--with-esd-prefix=PFX   Prefix where ESD is installed (optional)
#--with-esd-exec-prefix=PFX Exec prefix where ESD is installed (optional)


make clean
make
make install
cd $BASEDIR



#https://www.freedesktop.org/wiki/Software/HarfBuzz/
#complex package requires ICU flus freetype circular dependency
#$AD_HARFBUZZ/./configure -h --enable-static

#permissive with advertising
#https://freetype.org/index.html
echo "Building Freetype"
rm -rf temp
mkdir temp
cd temp
$AD_FREETYPE/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix=$AD_FREETYPE/build --exec-prefix=$AD_FREETYPE/build/$AD_EXEC ZLIB_CFLAGS=-I$AD_ZLIB/build/include ZLIB_LIBS=$AD_ZLIB/build/$AD_EXEC BZIP2_CFLAGS=-I$AD_BZIP/build/$AD_EXEC/include BZIP2_LIBS=$AD_BZIP/build/$AD_EXEC/lib LIBPNG_CFLAGS=-I$AD_LIBPNG/build/include LIBPNG_LIBS=$AD_LIBPNG/build/$AD_EXEC --with-harfbuzz=no
make clean
make
make install
cd $BASEDIR


#HARFBUZZ_CFLAGS C compiler flags for HARFBUZZ, overriding pkg-config
#HARFBUZZ_LIBS linker flags for HARFBUZZ, overriding pkg-config



#permissive
#$AD_LIBWEBP/./autogen.sh
echo "Building libwebp"
rm -rf temp
mkdir temp
cd temp
$AD_LIBWEBP/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-png --with-jpegincludedir=$AD_LIBJPG/build/include --with-jpeglibdir=$AD_LIBJPG/build/$AD_EXEC/lib --with-tiffincludedir=$AD_LIBTIF/build/include --with-tifflibdir=$AD_LIBTIF/build/$AD_EXEC/lib --with-gifincludedir=$AD_LIBGIF/build/include  --with-giflibdir=$AD_LIBGIF/build/$AD_EXEC/lib --with-pngincludedir=$AD_LIBPNG/build/include --with-pnglibdir=$AD_LIBPNG/build/$AD_EXEC/lib --prefix=$AD_LIBWEBP/build --exec-prefix=$AD_LIBWEBP/build/$AD_EXEC LDFLAGS="-L$AD_LIBPNG/build/$AD_EXEC/lib -L$AD_ZLIB/build/$AD_EXEC/lib" LIBS="-lm -lpng -lz"
make clean
make
make install
cd $BASEDIR

fi

#permissive
#compile error in config https://github.com/Linuxbrew/legacy-linuxbrew/issues/172
#seems to use sdl lib location for webp

echo "Building SDL2_image"
#cd $AD_SDL2_IMAGE
rm -rf temp
mkdir temp
cd temp

if [ OS = "macos" ]
then

    $AD_SDL2_IMAGE/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_IMAGE/build --exec-prefix=$AD_SDL2_IMAGE/build/$AD_EXEC SDL_CFLAGS=-I$AD_SDL2/build/include/SDL2 SDL_LIBS=-L$AD_SDL2/build/$AD_EXEC/lib LIBPNG_CFLAGS=-I$AD_LIBPNG/build/include LIBPNG_LIBS=-L$AD_LIBPNG/build/$AD_EXEC/lib LIBWEBP_CFLAGS=-I$AD_LIBWEBP/build/include LIBWEBP_LIBS=-L$AD_LIBWEBP/build/$AD_EXEC/lib LDFLAGS="-L$AD_LIBWEBP/build/$AD_EXEC/lib -L$AD_LIBTIF/build/$AD_EXEC/lib -L$AD_LIBGIF/build/$AD_EXEC/lib -L$AD_LIBJPG/build/$AD_EXEC/lib -L$AD_SDL2/build/$AD_EXEC/lib -L$AD_LIBPNG/build/$AD_EXEC/lib" 

    make clean
    make LIBS="-lSDL2 -framework CoreVideo -framework CoreGraphics -framework ImageIO -framework CoreAudio -framework AudioToolbox -framework Foundation -framework CoreFoundation -framework CoreServices -framework OpenGL -framework ForceFeedback -framework IOKit -framework Cocoa -framework Carbon"
    make install

else

    $AD_SDL2_IMAGE/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_IMAGE/build --exec-prefix=$AD_SDL2_IMAGE/build/$AD_EXEC SDL_CFLAGS=-I$AD_SDL2/build/include/SDL2 SDL_LIBS=-L$AD_SDL2/build/$AD_EXEC/lib LIBPNG_CFLAGS=-I$AD_LIBPNG/build/include LIBPNG_LIBS=-L$AD_LIBPNG/build/$AD_EXEC/lib LIBWEBP_CFLAGS=-I$AD_LIBWEBP/build/include LIBWEBP_LIBS=-L$AD_LIBWEBP/build/$AD_EXEC/lib LDFLAGS="-L$AD_LIBWEBP/build/$AD_EXEC/lib -L$AD_LIBTIF/build/$AD_EXEC/lib -L$AD_LIBGIF/build/$AD_EXEC/lib -L$AD_LIBJPG/build/$AD_EXEC/lib -L$AD_SDL2/build/$AD_EXEC/lib -L$AD_LIBPNG/build/$AD_EXEC/lib -L$AD_ZLIB/build/$AD_EXEC/lib -L$AD_XZ/build/$AD_EXEC/lib" CPPFLAGS="-I$AD_LIBWEBP/build/include -I$AD_LIBTIF/build/include -I$AD_LIBGIF/build/include -I$AD_LIBJPG/build/include -I$AD_SDL2/build/include -I$AD_LIBPNG/build/include" LIBS="-lSDL2 -llzma -lm"

    make clean
    make
    make install

fi
cd $BASEDIR


if false
then


echo "Building SDL2_ttf"
$AD_SDL2_TTF/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_TTF/build --exec-prefix=$AD_SDL2_TTF/build/$AD_EXEC --with-freetype-prefix=$AD_FREETYPE/build/include --with-freetype-exec-prefix=$AD_FREETYPE/build/$AD_EXEC --with-sdl-prefix=$AD_SDL2/build --with-sdl-exec-prefix=$AD_SDL2/build/$AD_EXEC
make clean
make
make install




echo "Building SDL2_net"
$AD_SDL2_NET/./configure CFLAGS="$AD_CFLAGS" CXXFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_NET/build --exec-prefix=$AD_SDL2_NET/build/$AD_EXEC --with-sdl-prefix=$AD_SDL2/build --with-sdl-exec-prefix=$AD_SDL2/build/$AD_EXEC
make clean
make
make install

fi

