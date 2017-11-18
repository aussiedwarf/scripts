#!/bin/bash
set -x #echo on
#./build.sh -c clang -o ubuntu16.04 -a x64
#./build.sh -c mingw -b sdl2 2>&1 | tee output.log
#./build.sh -c msvc -b zlib 2>&1 | tee output.log
#
# static          static lib linked to static libs
# shared_all      shared lib linked to shared libs
# shared_static   shared lib linked to static libs
#
# Delete already compiled build
# Copy other builds to temp
# Delete Dest
# Copy Source to Dest
# Goto Dest
# Build Dest
# Copy build to temp
# Delete Dest
# Copy source to Dest
# copy temp to dest
# Gotostart


AD_OS=macos
AD_ARCH=x64
AD_COMPILER=clang
AD_PROFILE=release
AD_CC=gcc
AD_CXX=g++
AD_MAKE=make
AD_AR=libtool
AD_AS=as
AD_LD=ld
AD_RC=rc
AD_STRIP=strip
AD_DLLTOOL=dlltool
AD_RANLIB=ranlib
AD_DIR=../thirdparty

AD_THREADS=1
#AD_HARFBUZZ=$AD_DIR/harfbuzz/harfbuzz-1.4.6





#script will build all libs unless specifically told to build a library. It will then only
#build said library(s)
AD_BUILD_ALL=true
AD_BUILD_ZLIB=false
AD_BUILD_LIBPNG=false
AD_BUILD_LIBJPEG=false
AD_BUILD_LIBJPEGTURBO=false
AD_BUILD_XZ=false
AD_BUILD_LIBTIFF=false
AD_BUILD_LIBWEBP=false
AD_BUILD_GIFLIB=false
AD_BUILD_FREETYPE=false
AD_BUILD_BZIP=false
AD_BUILD_LIBBPG=false
AD_BUILD_SDL2=false
AD_BUILD_SDL2_IMAGE=false
AD_BUILD_SDL2_TTF=false
AD_BUILD_SDL2_NET=false



SetBuild()
{
  echo "Set Build $1"
  AD_BUILD_ALL=false
  
  case $1 in
    zlib )          AD_BUILD_ZLIB=true;;
    libpng )        AD_BUILD_LIBPNG=true;;
    libjpeg )       AD_BUILD_LIBJPEG=true;;
    libjpegturbo )  AD_BUILD_LIBJPEGTURBO=true;;
    xz )            AD_BUILD_XZ=true;;
    libtiff )       AD_BUILD_LIBTIFF=true;;
    libwebp )       AD_BUILD_LIBWEBP=true;;
    giflib )        AD_BUILD_GIFLIB=true;;
    freetype )      AD_BUILD_FREETYPE=true;;
    bzip )          AD_BUILD_BZIP=true;;
    libbpg )        AD_BUILD_LIBBPG=true;;
    sdl2 )          AD_BUILD_SDL2=true;;
    sdl2_image )    AD_BUILD_SDL2_IMAGE=true;;
    sdl2_ttf )      AD_BUILD_SDL2_TTF=true;;
    sdl2_net )      AD_BUILD_SDL2_NET=true;;
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

#check for WSL
if [ AD_OS="linux" ] ; then
  if grep -q Microsoft /proc/version; then
    AD_OS="windows"
  fi
fi

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
  windows )   AD_ARCH=x64
              AD_COMPILER=msvc14
              AD_PROFILE=release
              AD_CC=cl.exe
              AD_CXX=cl.exe
              AD_MAKE=make
              AD_AR=link.exe
esac


BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPDIR="${BASEDIR}/temp"



echo "Running script from $BASEDIR"
echo "Currently in $TEMPDIR"


while [ "$1" != "" ]; do
    case $1 in
        -b | --build )          shift
                                echo "build: $1"
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
                                echo "compiler: $1"
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

#Get abs path to dest directory
echo "Thirdparty directory: $AD_DIR"
test -d "$AD_DIR" || mkdir -p "$AD_DIR" && cd $AD_DIR
AD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

echo "Thirdparty directory: $AD_DIR"

AD_ZLIB_DIR=zlib-1.2.11
AD_ZLIB=zlib
AD_ZLIB_FULL="$AD_DIR/$AD_ZLIB/$AD_ZLIB_DIR"

AD_LIBPNG_DIR=libpng-1.6.32
AD_LIBPNG=libpng
AD_LIBPNG_FULL="$AD_DIR/$AD_LIBPNG/$AD_LIBPNG_DIR"

AD_LIBJPG_DIR=jpeg-9b
AD_LIBJPG=libjpeg 
AD_LIBJPG_FULL="$AD_DIR/$AD_LIBJPG/$AD_LIBJPG_DIR"

AD_LIBJPGTURBO_DIR=libjpeg-turbo-1.5.2
AD_LIBJPGTURBO=libjpeg-turbo
AD_LIBJPGTURBO_FULL="$AD_DIR/$AD_LIBJPGTURBO/$AD_LIBJPGTURBO_DIR"

AD_XZ_DIR=xz-5.2.3
AD_XZ=xz
AD_XZ_FULL="$AD_DIR/$AD_XZ/$AD_XZ_DIR"

AD_LIBTIFF_DIR=tiff-4.0.8
AD_LIBTIFF=libtiff
AD_LIBTIFF_FULL="$AD_DIR/$AD_LIBTIFF/$AD_LIBTIFF_DIR"

#todo change to version from git
AD_LIBWEBP_DIR=master
AD_LIBWEBP=webp
AD_LIBWEBP_FULL="$AD_DIR/$AD_LIBWEBP/$AD_LIBWEBP_DIR"

AD_GIFLIB_DIR=giflib-5.1.4
AD_GIFLIB=giflib
AD_GIFLIB_FULL="$AD_DIR/$AD_GIFLIB/$AD_GIFLIB_DIR"

AD_FREETYPE_DIR=freetype-2.8
AD_FREETYPE=freetype
AD_FREETYPE_FULL="$AD_DIR/$AD_FREETYPE/$AD_FREETYPE_DIR"

AD_BZIP_DIR=bzip2-1.0.6
AD_BZIP=bzip2
AD_BZIP_FULL="$AD_DIR/$AD_BZIP/$AD_BZIP_DIR"

AD_LIBBPG_DIR=libbpg-0.9.7
AD_LIBBPG=libbpg
AD_LIBBPG_FULL="$AD_DIR/$AD_LIBBPG/$AD_LIBBPG_DIR"

#AD_JBIGKIT=$AD_DIR/

AD_SDL2_DIR=SDL2-2.0.6
AD_SDL2=SDL
AD_SDL2_FULL="$AD_DIR/$AD_SDL2/$AD_SDL2_DIR"

AD_SDL2_IMAGE_DIR=SDL2_image-2.0.1
AD_SDL2_IMAGE=SDL
AD_SDL2_IMAGE_FULL="$AD_DIR/$AD_SDL2_IMAGE/$AD_SDL2_IMAGE_DIR"

AD_SDL2_TTF_DIR=SDL2_ttf-2.0.14
AD_SDL2_TTF=SDL
AD_SDL2_TTF_FULL="$AD_DIR/$AD_SDL2_TTF/$AD_SDL2_TTF_DIR"

AD_SDL2_NET_DIR=SDL2_net-2.0.1
AD_SDL2_NET=SDL
AD_SDL2_NET_FULL="$AD_DIR/$AD_SDL2_NET/$AD_SDL2_NET_DIR"

#http://blog.httrack.com/blog/2014/03/09/what-are-your-gcc-flags/
AD_CFLAGS="-D_FILE_OFFSET_BITS=64 -Wall -O3 -fomit-frame-pointer -funroll-loops"
AD_CFLAGS_DEBUG="-D_FILE_OFFSET_BITS=64 -Wall -g"
# -msse4.1 -msse4.2 -msse4
# -frename-registers not for clang

if [ "$AD_COMPILER" = "gcc" ]
then
    AD_CFLAGS="$AD_CFLAGS -frename-registers"
    AD_CC="gcc"
    AD_CXX="g++"
    AD_CFLAGS_DEBUG="$AD_CFLAGS_DEBUG -Og"
fi

if [ "$AD_COMPILER" = "mingw" ]
then
    AD_CFLAGS="$AD_CFLAGS -frename-registers"
    AD_CC="translate.sh gcc.exe"
    AD_CXX="translate.sh g++.exe"
    AD_AR="translate.sh ar.exe"
    AD_LD="translate.sh ld.exe"
    AD_STRIP="translate.sh strip.exe"
    AD_AS="translate.sh as.exe"
    AD_RC="translate.sh windres.exe"
    AD_DLLTOOL="translate.sh dlltool.exe"
    AD_RANLIB="translate.sh ranlib.exe"
    AD_CFLAGS_DEBUG="$AD_CFLAGS_DEBUG -Og"
    
    export PATH="$PATH:$BASEDIR"
    echo "PATH: $PATH"
fi

if [ "$AD_COMPILER" = "clang" ]
then
    AD_CC="clang"
    AD_CXX="clang++"
    #Clang 3.8 does not accept -O0 on ubuntu 16.04
    AD_CFLAGS_DEBUG="$AD_CFLAGS_DEBUG -O0"
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

if [ "$AD_COMPILER" = "msvc14" ] || [ "$AD_COMPILER" = "msvc15" ]
then
  AD_CFLAGS="/O2"
  AD_CFLAGS_DEBUG="/Od"
  
  export PATH="$PATH:$BASEDIR"
    echo "PATH: $PATH"
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
    rm -rf "$AD_DIR/$1/$2/build/$3"
    #copy builds with other settings
    echo "Copying $AD_DIR/$1/$2/build TO $TEMPDIR/build"
    mv "$AD_DIR/$1/$2/build" "$TEMPDIR"
    
    echo "Removing $AD_DIR/$1/$2"
    rm -rf "$AD_DIR/$1/$2"
    
    echo "Copying $BASEDIR/thirdparty/$1/$2 TO $AD_DIR/$1/"
    test -d "$AD_DIR/$1" || mkdir -p "$AD_DIR/$1" && cp -a "$BASEDIR/thirdparty/$1/$2" "$AD_DIR/$1"
    
    cd "$AD_DIR/$1/$2"
}


EndBuild()
{
    test -d "$TEMPDIR/build/$3" || mkdir -p "$TEMPDIR/build/$3" && mv "$AD_DIR/$1/$2/build/$3" "$TEMPDIR/build/$3/../"
    
    rm -rf "$AD_DIR/$1/$2"
    
    echo "Copying $BASEDIR/thirdparty/$1/$2 TO $AD_DIR/$1/"
    test -d "$AD_DIR/$1" || mkdir -p "$AD_DIR/$1" && cp -a "$BASEDIR/thirdparty/$1/$2" "$AD_DIR/$1"
    
    mv "$TEMPDIR/build" "$AD_DIR/$1/$2"
    
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
    
    
    if [ "$AD_COMPILER" == "msvc14" ] || [ "$AD_COMPILER" == "msvc15" ]
    then
      echo COMPILE MSVC
      TPLATFORM=x64
      TCONFIG=Release
      
      if [ $3 = "x86" ]; then
        TPLATFORM=Win32
      fi
      
      if [ $4 = "debug" ]; then
        TCONFIG="Debug"
      fi
      
      StartBuild $AD_ZLIB $AD_ZLIB_DIR $1
      
      #copy vsproject
      cp $BASEDIR/thirdparty/$AD_ZLIB/zlibstat.vcxproj_14 $AD_DIR/$AD_ZLIB/zlibstat.vcxproj
      cp $BASEDIR/thirdparty/$AD_ZLIB/zlibvc.vcxproj_14 $AD_DIR/$AD_ZLIB/zlibvc.vcxproj
      
      translate.sh MSBuild.exe $AD_ZLIB_FULL/contrib/vstudio/vc14/zlibvc.sln /p:Configuration="$TCONFIG" /p:Platform="$TPLATFORM"
      
      TSTATFOLDER=ZlibStatRelease
      TDLLFOLDER=ZlibDllRelease
      if [ $4 == "debug" ] || [ $4 == "debug-static" ] || [ $4 == "debug-shared" ]; then
        TSTATFOLDER=ZlibStatDebug
        TDLLFOLDER=ZlibDllDebug
      fi
      
      #copy build
      test -d "$AD_ZLIB_FULL/build/$1" || mkdir -p "$AD_ZLIB_FULL/build/$1" && cp -a $AD_ZLIB_FULL/contrib/vstudio/vc14/$TPLATFORM/$TSTATFOLDER "$AD_ZLIB_FULL/build/$1"
      test -d "$AD_ZLIB_FULL/build/$1" || mkdir -p "$AD_ZLIB_FULL/build/$1" && cp -a $AD_ZLIB_FULL/contrib/vstudio/vc14/$TPLATFORM/ $TDLLFOLDER "$AD_ZLIB_FULL/build/$1"
      
      EndBuild $AD_ZLIB $AD_ZLIB_DIR $1
      
    else
      echo COMPILE GCC
      STATIC=""
      if [ $2 = "static" ]; then
        STATIC="--static"
      fi
      
      CFLAGS=$AD_CFLAGS
      if [ $4 = "debug" ]; then
        CFLAGS=$AD_CFLAGS_DEBUG
      fi
      
      StartBuild $AD_ZLIB $AD_ZLIB_DIR $1
      
      CONFIG_OPT=""
      if [ $AD_COMPILER = "mingw" ]; then
        STATIC="SHARED_MODE=0"
        if [ $2 = "shared" ]; then
          STATIC="SHARED_MODE=1"
        fi
        
        
        echo Make
        $AD_MAKE "-f$AD_ZLIB_FULL/win32/Makefile.gcc" CFLAGS="$CFLAGS" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" -j"$AD_THREADS" AS="$AD_AS" STRIP="$AD_STRIP" RC="$AD_RC" 
        CheckStatus "Zlib"
        $AD_MAKE "-fwin32/Makefile.gcc" install DESTDIR="$AD_ZLIB_FULL/build/$1" "$STATIC"
        
      else

        CC="$AD_CC" $AD_ZLIB_FULL/./configure $STATIC --prefix=$AD_ZLIB_FULL/build --eprefix=$AD_ZLIB_FULL/build/$1 $CONFIG_OPT
      
        CheckStatus "Zlib"
        echo Make
        $AD_MAKE CFLAGS="$CFLAGS" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" -j"$AD_THREADS" LD="$AD_CC"
        CheckStatus "Zlib"
        $AD_MAKE install
      
      fi
      #EndBuild "$AD_ZLIB_FULL"
      EndBuild $AD_ZLIB $AD_ZLIB_DIR $1
    fi
  fi
}




#libPNG license (permissive)
#http://www.libpng.org/pub/png/libpng.html
#requires zlib
#cmake ..\ --trace -G "MinGW Makefiles" -DCMAKE_INSTALL_PREFIX="C:\Users\aussiedwarf\dev\thirdparty\libpng\libpng-1.6.32-test\cbuild\build" -DZLIB_LIBRARY:FILEPATH="C:\Users\aussiedwarf\dev\thirdparty\zlib\zlib-1.2.11\build\windows\mingw\x64\release-shared\libz.a" -DZLIB_INCLUDE_DIR:PATH="C:\Users\aussiedwarf\dev\thirdparty\zlib\zlib-1.2.11\build\windows\mingw\x64\release-shared" -DCMAKE_C_FLAGS="-D_FILE_OFFSET_BITS=64 -Wall -O3 -fomit-frame-pointer -funroll-loops -frename-registers -mfpmath=sse -msse -msse2 -msse3 -mssse3" -DCMAKE_CXX_FLAGS="-D_FILE_OFFSET_BITS=64 -Wall -O3 -fomit-frame-pointer -funroll-loops -frename-registers -mfpmath=sse -msse -msse2 -msse3 -mssse3" > output.log 2>&1
#mingw32-make VERBOSE=1 > output.log 2>&1
BuildLibpng()
{
  if [ "$5" = "free" ]; then
    echo "Building libpng"
    
    echo $AD_COMPILER
    
    if [ "$AD_COMPILER" = "msvc*" ]
    then
    
      msbuild.exe $AD_LIBPNG_FULL/contrib/vstudio/vc14/zlibvc.sln
    
    else
      FLAGS=""
      if [ "$AD_COMPILER" = "mingw" ]
      then
        FLAGS="$FLAGS --host=mingw32"
      fi
      
      CFLAGS=$AD_CFLAGS
      if [ "$4" = "debug" ]; then
        CFLAGS=$AD_CFLAGS_DEBUG
      fi
    
      #STATIC="--disable-static"
      SHARED="--disable-shared"
      STATIC="--enable-static"
      #SHARED="--enable-shared"
      
      if [ "$2" = "static" ]; then
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
      
      
      $AD_LIBPNG_FULL/./configure CFLAGS="$CFLAGS" "$SSE" "$SHARED" "$STATIC" LDFLAGS=-L$AD_ZLIB_FULL/build/$1/lib --prefix=$AD_LIBPNG_FULL/build --exec-prefix=$AD_LIBPNG_FULL/build/$1 CPPFLAGS="-I$AD_ZLIB_FULL/build/include" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" $FLAGS
      
      
      
      CheckStatus "libpng"
      $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"

      #mingw has error compiling so needs to correct pnglibconf.h
      #THen retry building
      if [ "$AD_COMPILER" = "mingw" ]
      then
        #pnglibconf.h is generated by the makefile
        
        sed -i '/^#define PNG_TEXT_Z_DEFAULT_COMPRESSION/{N;s/\r//;}' pnglibconf.h
        sed -i '/^#define PNG_TEXT_Z_DEFAULT_STRATEGY/{N;s/\r//;}' pnglibconf.h
        sed -i '/^#define PNG_ZLIB_VERNUM/{N;s/\r//;}' pnglibconf.h
        sed -i '/^#define PNG_Z_DEFAULT_COMPRESSION/{N;s/\r//;}' pnglibconf.h
        sed -i '/^#define PNG_Z_DEFAULT_NOFILTER_STRATEGY/{N;s/\r//;}' pnglibconf.h
        sed -i '/^#define PNG_Z_DEFAULT_STRATEGY/{N;s/\r//;}' pnglibconf.h
        
        $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
      fi
      
      CheckStatus "libpng"
      
      if [ "$AD_COMPILER" = "mingw" ]
      then
        #rename windows files to unix in .dep foler
        if cd .deps ; then
          sed -i -- 's/C:/\/mnt\/c/g' *
          cd ../
        fi
        
        if cd contrib/libtests/.deps ; then
          sed -i -- 's/C:/\/mnt\/c/g' *
          cd ../../../
        fi
        
        
        if cd contrib/tools/.deps ; then
          sed -i -- 's/C:/\/mnt\/c/g' *
          cd ../../../
        fi
        
        if cd intel/.deps ; then
          sed -i -- 's/C:/\/mnt\/c/g' *
          cd ../../
        fi
        
        if cd mips/.deps ; then
          sed -i -- 's/C:/\/mnt\/c/g' *
          cd ../../
        fi
        
        if cd powerpc/.deps ; then
          sed -i -- 's/C:/\/mnt\/c/g' *
          cd ../../
        fi
      fi
      $AD_MAKE install
      
      #need to compile shared libs
      if [ "$AD_COMPILER" = "mingw" ] && [ "$SHARED" = "--enable-shared" ]
      then
        TEMPPATH="$AD_LIBPNG_FULL/build/$1/lib/libpng.dll.a"
        TEMPPATH=${TEMPPATH:6}
      
        $AD_CC $AD_LIBPNG_FULL/build/$1/lib/libpng16.a -shared -o $AD_LIBPNG_FULL/build/$1/lib/libpng.dll -Wl,--out-implib,"$TEMPPATH"
        # gcc.exe -shared -o libpng.dll libpng16.a -W1,--out-implib,libpng.dll.a
        #C:/Users/aussiedwarf/dev/thirdparty/libpng/libpng-1.6.32/build/windows/mingw/x64/release-static/lib/
        CheckStatus "libpng"
      fi
      
      EndBuild $AD_LIBPNG $AD_LIBPNG_DIR $1
    fi
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
    
    $AD_LIBJPG_FULL/./configure CFLAGS="$CFLAGS" "$SHARED" --prefix=$AD_LIBJPG_FULL/build --exec-prefix=$AD_LIBJPG_FULL/build/$1 CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB"
    CheckStatus "libjpeg"
    $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
    CheckStatus "libjpeg"
    
    if [ "$AD_COMPILER" = "mingw" ]
    then
      #rename windows files to unix in .dep foler
      if cd .deps ; then
        sed -i -- 's/C:/\/mnt\/c/g' *
        cd ../
      fi
    fi
    $AD_MAKE install
    EndBuild $AD_LIBJPG $AD_LIBJPG_DIR $1

  fi
}


BuildLibjpegturbo()
{
  echo building turbo libjpeg
}

#LZMA
#public domain
#https://tukaani.org/xz/
BuildXz()
{
  
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

}

#permissive
#http://www.simplesystems.org/libtiff/
#requires xz, zlib, libjpg
BuildLibtiff()
{
  echo "Building libtiff"
  StartBuild $AD_LIBTIFF $AD_LIBTIFF_DIR
  $AD_LIBTIFF/./configure CFLAGS="$AD_CFLAGS" --disable-shared --with-zlib-include-dir=$AD_ZLIB/build/include --with-zlib-lib-dir=$AD_ZLIB/build/$AD_EXEC/lib --with-jpeg-include-dir=$AD_LIBJPG/build/include --with-jpeg-lib-dir=$AD_LIBJPG/build/$AD_EXEC/lib --with-lzma-include-dir=$AD_XZ/build/include --with-lzma-lib-dir=$AD_XZ/build/$AD_EXEC/lib  --prefix=$AD_LIBTIFF/build --exec-prefix=$AD_LIBTIFF/build/$AD_EXEC CC="$AD_CC" CXX="$AD_CXX"
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
  EndBuild $AD_LIBTIFF
}

#permissive
#$AD_LIBWEBP/./autogen.sh
BuildLibwebp()
{

  echo "Building libwebp"
  StartBuild $AD_LIBWEBP $AD_LIBWEBP_DIR
  $AD_LIBWEBP/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-png --with-jpegincludedir=$AD_LIBJPG/build/include --with-jpeglibdir=$AD_LIBJPG/build/$AD_EXEC/lib --with-tiffincludedir=$AD_LIBTIFF/build/include --with-tifflibdir=$AD_LIBTIFF/build/$AD_EXEC/lib --with-gifincludedir=$AD_GIFLIB/build/include  --with-giflibdir=$AD_GIFLIB/build/$AD_EXEC/lib --with-pngincludedir=$AD_LIBPNG/build/include --with-pnglibdir=$AD_LIBPNG/build/$AD_EXEC/lib --prefix=$AD_LIBWEBP/build --exec-prefix=$AD_LIBWEBP/build/$AD_EXEC LDFLAGS="-L$AD_LIBPNG/build/$AD_EXEC/lib -L$AD_ZLIB/build/$AD_EXEC/lib" LIBS="-lm -lpng -lz" CC="$AD_CC" CXX="$AD_CXX"
  CheckStatus "libwebp"
  $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
  CheckStatus "libwebp"
  $AD_MAKE install
  EndBuild $AD_LIBWEBP
}

#permissive
#http://giflib.sourceforge.net/
BuildGiflib()
{
  echo "Building giflib"
  StartBuild $AD_GIFLIB $AD_GIFLIB_DIR
  $AD_GIFLIB/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix=$AD_GIFLIB/build --exec-prefix=$AD_GIFLIB/build/$AD_EXEC CC="$AD_CC" CXX="$AD_CXX"
  CheckStatus "giflib"
  $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
  CheckStatus "giflib"
  $AD_MAKE install
  EndBuild $AD_GIFLIB
}

#permissive with advertising
#https://freetype.org/index.html
#requires zlib, libpng, bzip2, harfbuzz(currently disabled)
BuildFreetype()
{

  echo "Building Freetype"
  StartBuild $AD_FREETYPE $AD_FREETYPE_DIR
  $AD_FREETYPE/./configure CFLAGS="$AD_CFLAGS" --disable-shared --prefix=$AD_FREETYPE/build --exec-prefix=$AD_FREETYPE/build/$AD_EXEC ZLIB_CFLAGS=-I$AD_ZLIB/build/include ZLIB_LIBS=$AD_ZLIB/build/$AD_EXEC BZIP2_CFLAGS=-I$AD_BZIP/build/$AD_EXEC/include BZIP2_LIBS=$AD_BZIP/build/$AD_EXEC/lib LIBPNG_CFLAGS=-I$AD_LIBPNG/build/include LIBPNG_LIBS=$AD_LIBPNG/build/$AD_EXEC --with-harfbuzz=no CC="$AD_CC" CXX="$AD_CXX"
  CheckStatus "Freetype"
  #Adding cc and cxx here causes freetype to not compile
  $AD_MAKE -j"$AD_THREADS"
  CheckStatus "Freetype"
  $AD_MAKE install
  EndBuild $AD_FREETYPE
}

#permissive
#http://www.bzip.org/
BuildBzip()
{

  echo "Building bzip2"

  StartBuild $AD_BZIP $AD_BZIP_DIR

  cd $AD_BZIP
  $AD_MAKE clean
  $AD_MAKE CFLAGS="$AD_CFLAGS" CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
  CheckStatus "bzip2"
  $AD_MAKE install -f $AD_BZIP/Makefile  PREFIX=$AD_BZIP/build/$AD_EXEC
  EndBuild $AD_BZIP
}

#combiniation of lgpl and gpl
    #depends on libpng, zlib, sdl
BuildLibbpg()
{
  
  echo "Building libbpg"
  StartBuild $AD_LIBBPG $AD_LIBBPG_DIR
  cd $AD_LIBBPG
  echo "$AD_LIBPNG/build/$AD_EXEC/lib"
  C_INCLUDE_PATH="$C_INCLUDE_PATH:$AD_LIBPNG/build/include:$AD_LIBJPG/build/include" LIBRARY_PATH="$LIBRARY_PATH:$AD_LIBPNG/build/$AD_EXEC/lib:$AD_ZLIB/build/$AD_EXEC/lib:$AD_LIBJPG/build/$AD_EXEC/lib" $AD_MAKE CONFIG_APPLE=y prefix="build/$AD_EXEC" LIBS=-lz -j"$AD_THREADS"
  CheckStatus "libbpg"
  $AD_MAKE install
  cd $BASEDIR/temp
  EndBuild $AD_LIBBPG
}



#permissive
#
BuildSDL2()
{
  if [ $5 = "free" ]; then
    echo "Building SDL2"
    
    if [ "$AD_COMPILER" == "msvc" ]
    then
    
      StartBuild $AD_SDL2 $AD_SDL2_DIR $1
      
      EndBuild $AD_SDL2
    else
    
      StartBuild $AD_SDL2 $AD_SDL2_DIR $1
      
      TCFLAGS=$AD_CFLAGS
      if [ "$4" = "debug" ]; then
        TCFLAGS=$AD_CFLAGS_DEBUG
      fi
      
      $AD_SDL2_FULL/./configure CFLAGS="$TCFLAGS" --enable-sse2 --disable-shared --enable-static --prefix=$AD_SDL2_FULL/build --exec-prefix=$AD_SDL2_FULL/build/$AD_EXEC CC="$AD_CC" CXX="$AD_CXX"
      CheckStatus "SDL2"
      #ALSA or esd may be needed on linux for sound
      #--with-alsa-prefix=PFX  Prefix where Alsa library is installed(optional)
      #--with-alsa-inc-prefix=PFX  Prefix where include libraries are (optional)
      #--with-esd-prefix=PFX   Prefix where ESD is installed (optional)
      #--with-esd-exec-prefix=PFX Exec prefix where ESD is installed (optional)

      $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
      CheckStatus "SDL2"
      $AD_MAKE install
      EndBuild $AD_SDL2 $AD_SDL2_DIR $1
    
    fi
  fi
}

#permissive
#compile error in config https://github.com/Linuxbrew/legacy-linuxbrew/issues/172
#seems to use sdl lib location for webp

BuildSdl2Image()
{

  echo "Building SDL2_image"
  #cd $AD_SDL2_IMAGE
  StartBuild $AD_SDL2_IMAGE $AD_SDL2_IMAGE_DIR

  if [ $AD_OS = "macos" ]
  then
      $AD_SDL2_IMAGE/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_IMAGE/build --exec-prefix=$AD_SDL2_IMAGE/build/$AD_EXEC SDL_CFLAGS=-I$AD_SDL2/build/include/SDL2 SDL_LIBS=-L$AD_SDL2/build/$AD_EXEC/lib LIBPNG_CFLAGS=-I$AD_LIBPNG/build/include LIBPNG_LIBS=-L$AD_LIBPNG/build/$AD_EXEC/lib LIBWEBP_CFLAGS=-I$AD_LIBWEBP/build/include LIBWEBP_LIBS=-L$AD_LIBWEBP/build/$AD_EXEC/lib LDFLAGS="-L$AD_LIBWEBP/build/$AD_EXEC/lib -L$AD_LIBTIFF/build/$AD_EXEC/lib -L$AD_GIFLIB/build/$AD_EXEC/lib -L$AD_LIBJPG/build/$AD_EXEC/lib -L$AD_SDL2/build/$AD_EXEC/lib -L$AD_LIBPNG/build/$AD_EXEC/lib" CC="$AD_CC" CXX="$AD_CXX"
      CheckStatus "SDL2_image"
      $AD_MAKE LIBS="-lSDL2 -framework CoreVideo -framework CoreGraphics -framework ImageIO -framework CoreAudio -framework AudioToolbox -framework Foundation -framework CoreFoundation -framework CoreServices -framework OpenGL -framework ForceFeedback -framework IOKit -framework Cocoa -framework Carbon" CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
      CheckStatus "SDL2_image"


  else

      $AD_SDL2_IMAGE/./configure CFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_IMAGE/build --exec-prefix=$AD_SDL2_IMAGE/build/$AD_EXEC SDL_CFLAGS=-I$AD_SDL2/build/include/SDL2 SDL_LIBS=-L$AD_SDL2/build/$AD_EXEC/lib LIBPNG_CFLAGS=-I$AD_LIBPNG/build/include LIBPNG_LIBS=-L$AD_LIBPNG/build/$AD_EXEC/lib LIBWEBP_CFLAGS=-I$AD_LIBWEBP/build/include LIBWEBP_LIBS=-L$AD_LIBWEBP/build/$AD_EXEC/lib LDFLAGS="-L$AD_LIBWEBP/build/$AD_EXEC/lib -L$AD_LIBTIFF/build/$AD_EXEC/lib -L$AD_GIFLIB/build/$AD_EXEC/lib -L$AD_LIBJPG/build/$AD_EXEC/lib -L$AD_SDL2/build/$AD_EXEC/lib -L$AD_LIBPNG/build/$AD_EXEC/lib -L$AD_ZLIB/build/$AD_EXEC/lib -L$AD_XZ/build/$AD_EXEC/lib" CPPFLAGS="-I$AD_LIBWEBP/build/include -I$AD_LIBTIFF/build/include -I$AD_GIFLIB/build/include -I$AD_LIBJPG/build/include -I$AD_SDL2/build/include -I$AD_LIBPNG/build/include" LIBS="-lSDL2 -llzma -lm" CC="$AD_CC" CXX="$AD_CXX"
      CheckStatus "SDL2_image"
      
      $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
      CheckStatus "SDL2_image"


  fi
  make install
  EndBuild $AD_SDL2_IMAGE
}

BuildSdl2Ttf()
{
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
}

BuildSdl2Net()
{
  echo "Building SDL2_net"
  StartBuild $AD_SDL2_NET $AD_SDL2_NET_DIR
  $AD_SDL2_NET/./configure CFLAGS="$AD_CFLAGS" CXXFLAGS="$AD_CFLAGS" --disable-shared --enable-static --prefix=$AD_SDL2_NET/build --exec-prefix=$AD_SDL2_NET/build/$AD_EXEC --with-sdl-prefix=$AD_SDL2/build --with-sdl-exec-prefix=$AD_SDL2/build/$AD_EXEC CC="$AD_CC" CXX="$AD_CXX"
  CheckStatus "SDL2_net"
  $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
  CheckStatus "SDL2_net"
  $AD_MAKE install
  EndBuild $AD_SDL2_NET
}


if false
then



#https://www.freedesktop.org/wiki/Software/HarfBuzz/
#complex package requires ICU flus freetype circular dependency
#$AD_HARFBUZZ/./configure -h --enable-static


#HARFBUZZ_CFLAGS C compiler flags for HARFBUZZ, overriding pkg-config
#HARFBUZZ_LIBS linker flags for HARFBUZZ, overriding pkg-config


fi

#libcurl
#openssl
#ffmpeg


#STATIC=$1
#ARCH=$2
#PROFILE=$3
#LICENSE=$4
BuildAll()
{

  
  EXEC_DIR=$AD_OS/$AD_COMPILER/$2/$3-$1

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_ZLIB" = true ]
  then
    BuildZlib $EXEC_DIR $1 $2 $3 $4
  fi
  
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBPNG" = true ]
  then
    BuildLibpng $EXEC_DIR $1 $2 $3 $4
  fi
  
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBJPEG" = true ]
  then
    BuildLibjpeg $EXEC_DIR $1 $2 $3 $4
  fi
  
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBJPEGTURBO" = true ]
  then
    BuildLibjpegturbo $EXEC_DIR $1 $2 $3 $4
  fi
  
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_XZ" = true ]
  then
    BuildXz  $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBTIFF" = true ]
  then
    BuildLibtiff $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBWEBP" = true ]
  then
    BuildLibwebp $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_GIFLIB" = true ]
  then
    BuildGiflib $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_FREETYPE" = true ]
  then
    BuildFreetype $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBBZIP" = true ]
  then
    BuildBzip $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBBPG" = true ]
  then
    BuildLibbpg $EXEC_DIR $1 $2 $3 $4
  fi
   
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_SDL2" = true ]
  then
    BuildSdl2 $EXEC_DIR $1 $2 $3 $4
  fi
   
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_SDL2IMAGE" = true ]
  then
    BuildSdl2Image $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_SDL2_TTF" = true ]
  then
    BuildSdl2Ttf $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_SDL2_NET" = true ]
  then
    BuildSdl2Net $EXEC_DIR $1 $2 $3 $4
  fi
}

# $1 static/shared
# $2 arch
# $3 release/debug
BuildLicense()
{
  echo "Building Permissive libs"
  BuildAll $1 $2 $3 "free"
  
  echo "Building LGPL libs"
  BuildAll $1 $2 $3 "lgpl"
  
  echo "Building GPL libs"
  BuildAll $1 $2 $3 "gpl"
}

# $1 static/shared
# $2 arch
BuildProfile()
{
  echo "Building Release libs"
  BuildLicense $1 $2 "release"
  
  #echo "Building Debug libs"
  #BuildLicense $1 $2 "debug"
}

# $1 arch
BuildLib()
{
  echo "Building Static libs"
  BuildProfile "static" $1
  
  #echo "Building Shared libs"
  #BuildProfile "shared" $1
}

echo "$AD_BUILD_ALL"
BuildLib $AD_ARCH


