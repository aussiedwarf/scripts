#!/bin/bash
#./build.sh -c clang -o ubuntu16.04 -a x64


AD_OS=macos
AD_ARCH=x64
AD_COMPILER=clang
AD_PROFILE=release
AD_CC=gcc
AD_CXX=g++
AD_MAKE=make
AD_AR=libtool
AD_DIR=../thirdparty
AD_SDL2_DIR=SDL/SDL2-2.0.5
AD_SDL2="$AD_DIR/$AD_SDL2_DIR"
AD_SDL2_IMAGE_DIR=SDL/SDL2_image-2.0.1
AD_SDL2_IMAGE="$AD_DIR/$AD_SDL2_IMAGE_DIR"
AD_SDL2_TTF_DIR=SDL/SDL2_ttf-2.0.14
AD_SDL2_TTF="$AD_DIR/$AD_SDL2_TTF_DIR"
AD_SDL2_NET_DIR=SDL/SDL2_net-2.0.1
AD_SDL2_NET="$AD_DIR/$AD_SDL2_NET_DIR"
  
AD_LIBBPG_DIR=libbpg/libbpg-0.9.7
AD_LIBBPG="$AD_DIR/$AD_LIBBPG_DIR"         
#AD_JBIGKIT=$AD_DIR/
#~/dev/thirdparty/xz/xz-5.2.3
AD_XZ_DIR=xz/xz-5.2.3
AD_XZ="$AD_DIR/$AD_XZ_DIR"
AD_LIBTIF_DIR=libtiff/tiff-4.0.8
AD_LIBTIF="$AD_DIR/$AD_LIBTIF_DIR"
AD_LIBWEBP_DIR=libwebp/libwebp-0.6.0
AD_LIBWEBP=$AD_DIR/$AD_LIBWEBP_DIR
AD_LIBGIF_DIR=giflib/giflib-5.1.4
AD_LIBGIF="$AD_DIR/$AD_LIBGIF_DIR"
AD_FREETYPE_DIR=freetype/freetype-2.8
AD_FREETYPE="$AD_DIR/$AD_FREETYPE_DIR"
AD_BZIP_DIR=bzip2/bzip2-1.0.6
AD_BZIP="$AD_DIR/$AD_BZIP_DIR"
AD_THREADS=1
#AD_HARFBUZZ=$AD_DIR/harfbuzz/harfbuzz-1.4.6





#script will build all libs unless specifically told to build a library. It will then only
#build said library(s)
AD_BUILD_ALL=true
AD_BUILD_ZLIB=false
AD_BUILD_LIBPNG=false
AD_BUILD_LIBJPEG=false

SetBuild()
{
  echo "Set Build $1"
  AD_BUILD_ALL=false
  
  case $1 in
    zlib )    AD_BUILD_ZLIB=true;;
    libpng )  AD_BUILD_LIBPNG=true;;
    libjpeg ) AD_BUILD_LIBJPEG=true;;
  esac
}


lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

AD_FULL_OS=`lowercase \`uname\``
AD_KERNEL=`uname -r`
AD_MACH=`uname -m`



#This does not work in !/bin/sh on ubuntu so use bash instead 
case "$OSTYPE" in
  solaris* ) AD_OS="solaris" ;;
  darwin* )  AD_OS="macos" ;; 
  linux* )   AD_OS="linux" ;;
  bsd* )     AD_OS="bsd" ;;
  msys* )    AD_OS="msys" ;;
  * )        AD_OS="unknown" ;;
esac

case "$AD_OS" in
   macos )    AD_ARCH=x64
              AD_COMPILER=clang
              AD_PROFILE=release
              AD_CC=gcc
              AD_CXX=g++
              AD_MAKE=make
              AD_AR=libtool
              ;;
  linux )     AD_ARCH=x64
              AD_COMPILER=gcc
              AD_PROFILE=release
              AD_CC=gcc
              AD_CXX=g++
              AD_MAKE=make
              AD_AR=ar
              ;;
esac


BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPDIR="${BASEDIR}/temp"

#Get abs path to dest directory
cd $AD_DIR
AD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

AD_ZLIB_DIR=zlib-1.2.11
AD_ZLIB=zlib
AD_ZLIB_FULL="$AD_DIR/$AD_ZLIB/$AD_ZLIB_DIR"

AD_LIBPNG_DIR=libpng-1.6.32
AD_LIBPNG=libpng
AD_LIBPNG_FULL="$AD_DIR/$AD_LIBPNG/$AD_LIBPNG_DIR"

AD_LIBJPG_DIR=jpeg-9b
AD_LIBJPG=libjpeg 
AD_LIBJPG_FULL="$AD_DIR/$AD_LIBJPG/$AD_LIBJPG_DIR"

echo "Running script from $BASEDIR"
echo "Currently in $TEMPDIR"


while [ "$1" != "" ]; do
    case $1 in
        -b | --build )          shift
                                SetBuild $1
                                ;;
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
        -j | --threads )        shift
                                AD_THREADS=$1
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
AD_CFLAGS="-D_FILE_OFFSET_BITS=64 -Wall -O3 -fomit-frame-pointer -funroll-loops"
AD_CFLAGS_DEBUG="-D_FILE_OFFSET_BITS=64 -Wall -Og -g"
# -msse4.1 -msse4.2 -msse4
# -frename-registers not for clang

if [ "$AD_COMPILER" = "gcc" ]
then
    AD_CFLAGS="$AD_CFLAGS -frename-registers"
    AD_CC="gcc"
    AD_CXX="g++"
fi

if [ "$AD_COMPILER" = "clang" ]
then
    AD_CC="clang"
    AD_CXX="clang++"
fi

if [ "$AD_COMPILER" = "emscripten" ]
then
  AD_ARCH="all"
  AD_OS="all"
  AD_CC="emcc"
  AD_CXX="em++"
  AD_AR="emcc"
  AD_MAKE="emmake make"
fi

if [ "$AD_ARCH" = "x64" ] || [ "$AD_ARCH" = "x86" ]
then
   AD_CFLAGS="$AD_CFLAGS -mfpmath=sse -msse -msse2 -msse3 -mssse3"
fi

echo "CFLAGS: $AD_CFLAGS"


AD_EXEC=$AD_OS/$AD_COMPILER/$AD_ARCH/$AD_PROFILE
echo "Build dir: $AD_EXEC"


echo "Thirdparty directory: $AD_DIR"
echo "THREADS: $AD_THREADS"
echo "AR: $AD_AR"
 
# mac warns to not use -ra for cp
# $1 library name
# $2 folder version name
# $3 exec directory
StartBuild()
{

    #Remove previous temp  dir and create new one to hold builds for other systems
    rm -rf temp
    mkdir temp
    cd temp
    #remove previous build
    #echo "Removing $1/build/$3"
    echo "Removing $AD_DIR/$1/$2/build/$3"
    #rm -rf "$1/build/$3"
    rm -rf "$AD_DIR/$1/$2/build/$3"
    #copy builds with other settings
    #echo "Copying $1/build TO $TEMPDIR/build"
    echo "Copying $AD_DIR/$1/$2/build TO $TEMPDIR/build"
    #cp -a "$1/build" "$TEMPDIR/build"
    cp -a "$AD_DIR/$1/$2/build" "$TEMPDIR/build"
    #echo "Removing $1"
    echo "Removing $AD_DIR/$1/$2"
    #rm -rf "$1"
    rm -rf "$AD_DIR/$1/$2"
    #echo "Copying $BASEDIR/thirdparty/$2 TO $1"
    echo "Copying $BASEDIR/thirdparty/$1/$2 TO $AD_DIR/$1/"
    #test -d "$1" || mkdir -p "$1" && cp -a "$BASEDIR/thirdparty/$2" "$1"
    test -d "$AD_DIR/$1" || mkdir -p "$AD_DIR/$1" && cp -a "$BASEDIR/thirdparty/$1/$2" "$AD_DIR/$1"
    
}

EndBuild()
{
    echo "Copying $TEMPDIR/build TO $1"
    cp -a "$TEMPDIR/build" "$1"
    cd $BASEDIR
}

CheckStatus()
{
  if [ $? -ne 0 ];then
    echo "Error building $1"
    exit 1
  fi
}



#Build* functions take 2, sometime 3 parameters
#$1 install directory
#$2 is "static" or "shared"
#$3 is the arch, "x86", "x64", emscripten, arm, etc
#$4 is profile debug or release
#$5 is license, free, lgpl, gpl when needed

#zlib license
#https://zlib.net/
BuildZlib()
{
  if [ $5 = "free" ]; then
    echo "Building zlib"
    
    STATIC=""
    if [ $2 = "static" ]; then
      STATIC="--static"
    fi
    
    CFLAGS=$AD_CFLAGS
    if [ $4 = "debug" ]; then
      CFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    StartBuild $AD_ZLIB $AD_ZLIB_DIR $1
    
    $AD_ZLIB_FULL/./configure $STATIC --prefix=$AD_ZLIB_FULL/build --eprefix=$AD_ZLIB_FULL/build/$1
  
    CheckStatus "Zlib"
    $AD_MAKE CFLAGS="$CFLAGS" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" -j"$AD_THREADS"
    CheckStatus "Zlib"
    $AD_MAKE install
    EndBuild "$AD_ZLIB_FULL"
  fi
}




#libPNG license (permissive)
#http://www.libpng.org/pub/png/libpng.html
#requires zlib
BuildLibpng()
{
  if [ "$5" = "free" ]; then
    echo "Building libpng"
    
    CFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      CFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    STATIC="--disable-static"
    SHARED="--disable-shared"
    if [ $2 = "static" ]; then
      STATIC="--enable-static"
    else
      SHARED="--enable-shared"
    fi
    
    SSE=""
    
    if [ "$3" = "x86" ] || [ "$3" = "x64" ]
    then
      SSE="--enable-intel-sse"
    fi
    
    
    StartBuild $AD_LIBPNG $AD_LIBPNG_DIR $1
    #need to copy folder as ./configure does not copy
    
    
    echo CONFIGURE CFLAGS="$CFLAGS" "$SSE" "$SHARED" "$STATIC" LDFLAGS=-L$AD_ZLIB_FULL/build/$1/lib --prefix=$AD_LIBPNG_FULL/build --exec-prefix=$AD_LIBPNG_FULL/build/$1 CPPFLAGS="-I$AD_ZLIB_FULL/build/include" CC="$AD_CC" CXX="$AD_CXX"
    
    $AD_LIBPNG_FULL/./configure CFLAGS="$CFLAGS" "$SSE" "$SHARED" "$STATIC" LDFLAGS=-L$AD_ZLIB_FULL/build/$1/lib --prefix=$AD_LIBPNG_FULL/build --exec-prefix=$AD_LIBPNG_FULL/build/$1 CPPFLAGS="-I$AD_ZLIB_FULL/build/include" CC="$AD_CC" CXX="$AD_CXX"
    CheckStatus "libpng"
    $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
    CheckStatus "libpng"
    $AD_MAKE install
    EndBuild $AD_LIBPNG_FULL
  fi
}


#IJG libjpg
#Wikipedia says BSD like
#http://www.ijg.org/
#https://sourceforge.net/projects/libjpeg/
BuildLibjpeg()
{
  if [ "$5" = "free" ]; then
    echo "Building libjpeg"
    
    CFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      CFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    STATIC="--disable-static"
    SHARED="--disable-shared"
    if [ $2 = "static" ]; then
      STATIC="--enable-static"
    else
      SHARED="--enable-shared"
    fi
    
    StartBuild $AD_LIBJPG $AD_LIBJPG_DIR $1
    
    $AD_LIBJPG_FULL/./configure CFLAGS="$CFLAGS" "$SHARED" --prefix=$AD_LIBJPG_FULL/build --exec-prefix=$AD_LIBJPG_FULL/build/$1 CC="$AD_CC" CXX="$AD_CXX"
    CheckStatus "libjpeg"
    $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
    CheckStatus "libjpeg"
    $AD_MAKE install
    EndBuild $AD_LIBJPG_FULL
  fi
}

if false
then



#LZMA
#public domain
#https://tukaani.org/xz/
echo "Building xz"

#/home/hypergiant/dev/thirdparty/xz/xz-5.2.3/./configure CFLAGS="-D_FILE_OFFSET_BITS=64 -Wall -O3 -fomit-frame-pointer -funroll-loops -mfpmath=sse -msse -msse2 -msse3 -mssse3" --disable-shared --prefix="/home/hypergiant/dev/thirdparty/xz/xz-5.2.3/build" --exec-prefix="/home/hypergiant/dev/thirdparty/xz/xz-5.2.3/build/ubuntu16.04/gcc/x64/release"

#rm -rf temp
#mkdir temp
#cd temp
#$AD_XZ/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix="$AD_XZ/build" --exec-prefix="$AD_XZ/build/$AD_EXEC"
#make clean
#make
#make install
#cd $BASEDIR

StartBuild $AD_XZ $AD_XZ_DIR
$AD_XZ/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix="$AD_XZ/build" --exec-prefix="$AD_XZ/build/$AD_EXEC" CC="$AD_CC" CXX="$AD_CXX"
CheckStatus "xz"
$AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
CheckStatus "xz"
$AD_MAKE install
EndBuild $AD_XZ

#CC="$AD_CC" CXX="$AD_CXX"



#permissive
#http://www.simplesystems.org/libtiff/
#requires xz, zlib, libjpg
echo "Building libtiff"
StartBuild $AD_LIBTIF $AD_LIBTIF_DIR
$AD_LIBTIF/./configure CFLAGS="$AD_CFLAGS" --disable-shared --with-zlib-include-dir=$AD_ZLIB/build/include --with-zlib-lib-dir=$AD_ZLIB/build/$AD_EXEC/lib --with-jpeg-include-dir=$AD_LIBJPG/build/include --with-jpeg-lib-dir=$AD_LIBJPG/build/$AD_EXEC/lib --with-lzma-include-dir=$AD_XZ/build/include --with-lzma-lib-dir=$AD_XZ/build/$AD_EXEC/lib  --prefix=$AD_LIBTIF/build --exec-prefix=$AD_LIBTIF/build/$AD_EXEC CC="$AD_CC" CXX="$AD_CXX"
CheckStatus "libtiff"

#--with-jbig-include-dir=DIR location of JBIG-KIT headers which are GPL
#--with-jbig-lib-dir=DIR location of JBIG-KIT library binary
#unsure of source for libjpeg12
#looks to be ijg compiled again for 12bit but may need modifiedtiff and jpeg code to not clash
#don't need 12bit support
#--with-jpeg12-include-dir=DIR location of libjpeg 12bit headers
#--with-jpeg12-lib=LIBRARY path to libjpeg 12bit library

$AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
CheckStatus "libtiff"
$AD_MAKE install
EndBuild $AD_LIBTIF



#permissive
#http://giflib.sourceforge.net/
echo "Building giflib"
StartBuild $AD_LIBGIF $AD_LIBGIF_DIR
$AD_LIBGIF/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix=$AD_LIBGIF/build --exec-prefix=$AD_LIBGIF/build/$AD_EXEC CC="$AD_CC" CXX="$AD_CXX"
CheckStatus "giflib"
$AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
CheckStatus "giflib"
$AD_MAKE install
EndBuild $AD_LIBGIF



#permissive
#http://www.bzip.org/
echo "Building bzip2"

StartBuild $AD_BZIP $AD_BZIP_DIR

cd $AD_BZIP
$AD_MAKE clean
$AD_MAKE CFLAGS="$AD_CFLAGS" CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
CheckStatus "bzip2"
$AD_MAKE install -f $AD_BZIP/Makefile  PREFIX=$AD_BZIP/build/$AD_EXEC
EndBuild $AD_BZIP



#permissive
#
echo "Building SDL2"
StartBuild $AD_SDL2 $AD_SDL2_DIR
$AD_SDL2/./configure CFLAGS="$AD_CFLAGS" --enable-sse2 --disable-shared --enable-static --prefix=$AD_SDL2/build --exec-prefix=$AD_SDL2/build/$AD_EXEC CC="$AD_CC" CXX="$AD_CXX"
CheckStatus "SDL2"
#ALSA or esd may be needed on linux for sound
#--with-alsa-prefix=PFX  Prefix where Alsa library is installed(optional)
#--with-alsa-inc-prefix=PFX  Prefix where include libraries are (optional)
#--with-esd-prefix=PFX   Prefix where ESD is installed (optional)
#--with-esd-exec-prefix=PFX Exec prefix where ESD is installed (optional)

$AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
CheckStatus "SDL2"
$AD_MAKE install
EndBuild $AD_SDL2




#https://www.freedesktop.org/wiki/Software/HarfBuzz/
#complex package requires ICU flus freetype circular dependency
#$AD_HARFBUZZ/./configure -h --enable-static

#permissive with advertising
#https://freetype.org/index.html
#requires zlib, libpng, bzip2, harfbuzz(currently disabled)
echo "Building Freetype"
StartBuild $AD_FREETYPE $AD_FREETYPE_DIR
$AD_FREETYPE/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix=$AD_FREETYPE/build --exec-prefix=$AD_FREETYPE/build/$AD_EXEC ZLIB_CFLAGS=-I$AD_ZLIB/build/include ZLIB_LIBS=$AD_ZLIB/build/$AD_EXEC BZIP2_CFLAGS=-I$AD_BZIP/build/$AD_EXEC/include BZIP2_LIBS=$AD_BZIP/build/$AD_EXEC/lib LIBPNG_CFLAGS=-I$AD_LIBPNG/build/include LIBPNG_LIBS=$AD_LIBPNG/build/$AD_EXEC --with-harfbuzz=no CC="$AD_CC" CXX="$AD_CXX"
CheckStatus "Freetype"
#Adding cc and cxx here causes freetype to not compile
$AD_MAKE -j"$AD_THREADS"
CheckStatus "Freetype"
$AD_MAKE install
EndBuild $AD_FREETYPE



#HARFBUZZ_CFLAGS C compiler flags for HARFBUZZ, overriding pkg-config
#HARFBUZZ_LIBS linker flags for HARFBUZZ, overriding pkg-config



#permissive
#$AD_LIBWEBP/./autogen.sh
echo "Building libwebp"
StartBuild $AD_LIBWEBP $AD_LIBWEBP_DIR
$AD_LIBWEBP/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-png --with-jpegincludedir=$AD_LIBJPG/build/include --with-jpeglibdir=$AD_LIBJPG/build/$AD_EXEC/lib --with-tiffincludedir=$AD_LIBTIF/build/include --with-tifflibdir=$AD_LIBTIF/build/$AD_EXEC/lib --with-gifincludedir=$AD_LIBGIF/build/include  --with-giflibdir=$AD_LIBGIF/build/$AD_EXEC/lib --with-pngincludedir=$AD_LIBPNG/build/include --with-pnglibdir=$AD_LIBPNG/build/$AD_EXEC/lib --prefix=$AD_LIBWEBP/build --exec-prefix=$AD_LIBWEBP/build/$AD_EXEC LDFLAGS="-L$AD_LIBPNG/build/$AD_EXEC/lib -L$AD_ZLIB/build/$AD_EXEC/lib" LIBS="-lm -lpng -lz" CC="$AD_CC" CXX="$AD_CXX"
CheckStatus "libwebp"
$AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
CheckStatus "libwebp"
$AD_MAKE install
EndBuild $AD_LIBWEBP



#permissive
#compile error in config https://github.com/Linuxbrew/legacy-linuxbrew/issues/172
#seems to use sdl lib location for webp

echo "Building SDL2_image"
#cd $AD_SDL2_IMAGE
StartBuild $AD_SDL2_IMAGE $AD_SDL2_IMAGE_DIR

if [ $AD_OS = "macos" ]
then
    $AD_SDL2_IMAGE/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_IMAGE/build --exec-prefix=$AD_SDL2_IMAGE/build/$AD_EXEC SDL_CFLAGS=-I$AD_SDL2/build/include/SDL2 SDL_LIBS=-L$AD_SDL2/build/$AD_EXEC/lib LIBPNG_CFLAGS=-I$AD_LIBPNG/build/include LIBPNG_LIBS=-L$AD_LIBPNG/build/$AD_EXEC/lib LIBWEBP_CFLAGS=-I$AD_LIBWEBP/build/include LIBWEBP_LIBS=-L$AD_LIBWEBP/build/$AD_EXEC/lib LDFLAGS="-L$AD_LIBWEBP/build/$AD_EXEC/lib -L$AD_LIBTIF/build/$AD_EXEC/lib -L$AD_LIBGIF/build/$AD_EXEC/lib -L$AD_LIBJPG/build/$AD_EXEC/lib -L$AD_SDL2/build/$AD_EXEC/lib -L$AD_LIBPNG/build/$AD_EXEC/lib" CC="$AD_CC" CXX="$AD_CXX"
    CheckStatus "SDL2_image"
    $AD_MAKE LIBS="-lSDL2 -framework CoreVideo -framework CoreGraphics -framework ImageIO -framework CoreAudio -framework AudioToolbox -framework Foundation -framework CoreFoundation -framework CoreServices -framework OpenGL -framework ForceFeedback -framework IOKit -framework Cocoa -framework Carbon" CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
    CheckStatus "SDL2_image"


else

    $AD_SDL2_IMAGE/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_IMAGE/build --exec-prefix=$AD_SDL2_IMAGE/build/$AD_EXEC SDL_CFLAGS=-I$AD_SDL2/build/include/SDL2 SDL_LIBS=-L$AD_SDL2/build/$AD_EXEC/lib LIBPNG_CFLAGS=-I$AD_LIBPNG/build/include LIBPNG_LIBS=-L$AD_LIBPNG/build/$AD_EXEC/lib LIBWEBP_CFLAGS=-I$AD_LIBWEBP/build/include LIBWEBP_LIBS=-L$AD_LIBWEBP/build/$AD_EXEC/lib LDFLAGS="-L$AD_LIBWEBP/build/$AD_EXEC/lib -L$AD_LIBTIF/build/$AD_EXEC/lib -L$AD_LIBGIF/build/$AD_EXEC/lib -L$AD_LIBJPG/build/$AD_EXEC/lib -L$AD_SDL2/build/$AD_EXEC/lib -L$AD_LIBPNG/build/$AD_EXEC/lib -L$AD_ZLIB/build/$AD_EXEC/lib -L$AD_XZ/build/$AD_EXEC/lib" CPPFLAGS="-I$AD_LIBWEBP/build/include -I$AD_LIBTIF/build/include -I$AD_LIBGIF/build/include -I$AD_LIBJPG/build/include -I$AD_SDL2/build/include -I$AD_LIBPNG/build/include" LIBS="-lSDL2 -llzma -lm" CC="$AD_CC" CXX="$AD_CXX"
    CheckStatus "SDL2_image"
    
    $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
    CheckStatus "SDL2_image"


fi
make install
EndBuild $AD_SDL2_IMAGE


echo "Building SDL2_ttf"
StartBuild $AD_SDL2_TTF $AD_SDL2_TTF_DIR

if [ $AD_OS = "macos" ]
then

  $AD_SDL2_TTF/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_TTF/build --exec-prefix=$AD_SDL2_TTF/build/$AD_EXEC --with-freetype-prefix=$AD_FREETYPE/build/include/freetype2 --with-freetype-exec-prefix=$AD_FREETYPE/build/$AD_EXEC/lib --with-sdl-prefix=$AD_SDL2/build --with-sdl-exec-prefix=$AD_SDL2/build/$AD_EXEC CPPFLAGS="-I$AD_FREETYPE/build/include/freetype2" CC="$AD_CC" CXX="$AD_CXX"
  CheckStatus "SDL2_image"
  $AD_MAKE LIBS="-lfreetype -lSDL2 -lpng -lbz2 -framework CoreVideo -framework CoreGraphics -framework ImageIO -framework CoreAudio -framework AudioToolbox -framework Foundation -framework CoreFoundation -framework CoreServices -framework OpenGL -framework ForceFeedback -framework IOKit -framework Cocoa -framework Carbon" LDFLAGS="-L$AD_FREETYPE/build/$AD_EXEC/lib -L$AD_LIBPNG/build/$AD_EXEC/lib -L$AD_SDL2/build/$AD_EXEC/lib -L$AD_BZIP/build/$AD_EXEC/lib" CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
  CheckStatus "SDL2_image"

else

  $AD_SDL2_TTF/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_TTF/build --exec-prefix=$AD_SDL2_TTF/build/$AD_EXEC --with-freetype-prefix=$AD_FREETYPE/build/include/freetype2 --with-freetype-exec-prefix=$AD_FREETYPE/build/$AD_EXEC/lib --with-sdl-prefix=$AD_SDL2/build --with-sdl-exec-prefix=$AD_SDL2/build/$AD_EXEC CPPFLAGS="-I$AD_FREETYPE/build/include/freetype2" CC="$AD_CC" CXX="$AD_CXX"
  CheckStatus "SDL2_image"
  $AD_MAKE LIBS="-lfreetype -lSDL2 -lpng -lbz2 " LDFLAGS="-L$AD_FREETYPE/build/$AD_EXEC/lib -L$AD_LIBPNG/build/$AD_EXEC/lib -L$AD_SDL2/build/$AD_EXEC/lib -L$AD_BZIP/build/$AD_EXEC/lib" CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
  CheckStatus "SDL2_image"

fi

$AD_MAKE install
EndBuild $AD_SDL2_TTF


echo "Building SDL2_net"
StartBuild $AD_SDL2_NET $AD_SDL2_NET_DIR
$AD_SDL2_NET/./configure CFLAGS="$AD_CFLAGS" CXXFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_NET/build --exec-prefix=$AD_SDL2_NET/build/$AD_EXEC --with-sdl-prefix=$AD_SDL2/build --with-sdl-exec-prefix=$AD_SDL2/build/$AD_EXEC CC="$AD_CC" CXX="$AD_CXX"
CheckStatus "SDL2_net"
$AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
CheckStatus "SDL2_net"
$AD_MAKE install
EndBuild $AD_SDL2_NET



#combiniation of lgpl and gpl
#depends on libpng, zlib, sdl
echo "Building libbpg"
StartBuild $AD_LIBBPG $AD_LIBBPG_DIR
cd $AD_LIBBPG
echo "$AD_LIBPNG/build/$AD_EXEC/lib"
C_INCLUDE_PATH="$C_INCLUDE_PATH:$AD_LIBPNG/build/include:$AD_LIBJPG/build/include" LIBRARY_PATH="$LIBRARY_PATH:$AD_LIBPNG/build/$AD_EXEC/lib:$AD_ZLIB/build/$AD_EXEC/lib:$AD_LIBJPG/build/$AD_EXEC/lib" $AD_MAKE CONFIG_APPLE=y prefix="build/$AD_EXEC" LIBS=-lz -j"$AD_THREADS"
CheckStatus "libbpg"
$AD_MAKE install
cd $BASEDIR/temp
EndBuild $AD_LIBBPG

fi

#libcurl
#openssl
#ffmpeg



BuildAll()
{
  STATIC=$1
  ARCH=$2
  PROFILE=$3
  LICENSE=$4
  
  EXEC_DIR=$AD_OS/$AD_COMPILER/$ARCH/$PROFILE-$STATIC

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_ZLIB" = true ]
  then
    BuildZlib $EXEC_DIR $STATIC $ARCH $PROFILE $LICENSE
  fi
  
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBPNG" = true ]
  then
    BuildLibpng $EXEC_DIR $STATIC $ARCH $PROFILE $LICENSE
  fi
  
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBJPEG" = true ]
  then
    BuildLibjpeg $EXEC_DIR $STATIC $ARCH $PROFILE $LICENSE
  fi
}

BuildLicense()
{
  echo "Building Permissive libs"
  BuildAll $1 $2 $3 "free"
  
  echo "Building LGPL libs"
  BuildAll $1 $2 $3 "lgpl"
  
  echo "Building GPL libs"
  BuildAll $1 $2 $3 "gpl"
}

BuildProfile()
{
  echo "Building Release libs"
  BuildLicense $1 $2 "release"
  
  echo "Building Debug libs"
  BuildLicense $1 $2 "debug"
}


BuildLib()
{
  echo "Building Static libs"
  BuildProfile "static" $1
  
  echo "Building Shared libs"
  BuildProfile "shared" $1
}

echo "$AD_BUILD_ALL"
BuildLib $AD_ARCH


