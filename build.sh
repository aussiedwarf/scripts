#!/bin/bash
set -x #echo on
# ./build.sh -c gcc -o linux -a x64 -b sdl2 2>&1 | tee output.log
# ./build.sh -c clang -o linux -a x64
# ./build.sh -c clang -o macos -b zlib 2>&1 | tee output.log
# ./build.sh -c mingw -b giflib 2>&1 | tee output.log
# ./build.sh -c msvc15 -a x64 -b zlib 2>&1 | tee output.log
# ./build.sh -c msvc15 -a x86 -b zlib 2>&1 | tee output.log
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
AD_WINDRES=windres
AD_STRIP=strip
AD_DLLTOOL=dlltool
AD_RANLIB=ranlib
AD_DIR=../thirdparty
AD_NASM=nasm

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
AD_BUILD_GLEW=false


SetBuild()
{
  echo "Set Build $1"
  AD_BUILD_ALL=false
  
  case $1 in
    zlib )          AD_BUILD_ZLIB=true;;
    libpng )        AD_BUILD_LIBPNG=true;;
    png )           AD_BUILD_LIBPNG=true;;
    libjpeg )       AD_BUILD_LIBJPEG=true;;
    jpeg )          AD_BUILD_LIBJPEG=true;;
    libjpegturbo )  AD_BUILD_LIBJPEGTURBO=true;;
    jpegturbo )     AD_BUILD_LIBJPEGTURBO=true;;
    xz )            AD_BUILD_XZ=true;;
    libtiff )       AD_BUILD_LIBTIFF=true;;
    tiff )          AD_BUILD_LIBTIFF=true;;
    giflib )        AD_BUILD_GIFLIB=true;;
    libwebp )       AD_BUILD_LIBWEBP=true;;
    webp )          AD_BUILD_LIBWEBP=true;;
    bzip )          AD_BUILD_BZIP=true;;
    freetype )      AD_BUILD_FREETYPE=true;;
    libbpg )        AD_BUILD_LIBBPG=true;;
    sdl2 )          AD_BUILD_SDL2=true;;
    sdl2_image )    AD_BUILD_SDL2_IMAGE=true;;
    sdl2_ttf )      AD_BUILD_SDL2_TTF=true;;
    sdl2_net )      AD_BUILD_SDL2_NET=true;;
    glew )          AD_BUILD_GLEW=true;;
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
if [ $AD_OS="linux" ] ; then
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
              AD_COMPILER=msvc15
              AD_PROFILE=release
              AD_CC=cl.exe
              AD_CXX=cl.exe
              AD_MAKE=make
              AD_AR=link.exe
              ;;
  android )   AD_ARCH=armeabi
              AD_COMPILER=clang
              AD_PROFILE=release
              AD_CC=clang
              AD_CXX=clang++
              AD_MAKE=make
              AD_AR=llvm-ar
              AD_LD=llvm-link
              AD_AS=llvm-as
esac


BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPDIR="${BASEDIR}/temp"



echo "Running script from $BASEDIR"
echo "Currently in $TEMPDIR"

Usage ()
{
    echo "Usage: [[[-f file ] [-i]] | [-h]] "
}

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
        -h | --help )           Usage
                                exit
                                ;;
        * )                     Usage
                                exit 1
    esac
    shift
done



#Get abs path to dest directory
echo "Thirdparty directory: $AD_DIR"
test -d "$AD_DIR" || mkdir -p "$AD_DIR" && cd $AD_DIR
AD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

echo "Thirdparty directory: $AD_DIR"

AD_ZLIB_DIR=zlib-1.2.11
AD_ZLIB=zlib
AD_ZLIB_FULL="$AD_DIR/$AD_ZLIB/$AD_ZLIB_DIR"

AD_LIBPNG_DIR=libpng-1.6.37
AD_LIBPNG=libpng
AD_LIBPNG_FULL="$AD_DIR/$AD_LIBPNG/$AD_LIBPNG_DIR"

AD_LIBJPG_DIR=jpeg-9d
AD_LIBJPG=libjpeg 
AD_LIBJPG_FULL="$AD_DIR/$AD_LIBJPG/$AD_LIBJPG_DIR"

AD_LIBJPGTURBO_DIR=libjpeg-turbo-2.0.4
AD_LIBJPGTURBO=libjpeg-turbo
AD_LIBJPGTURBO_FULL="$AD_DIR/$AD_LIBJPGTURBO/$AD_LIBJPGTURBO_DIR"

AD_XZ_DIR=xz-5.2.4
AD_XZ=xz
AD_XZ_FULL="$AD_DIR/$AD_XZ/$AD_XZ_DIR"

AD_LIBTIFF_DIR=tiff-4.1.0
AD_LIBTIFF=libtiff
AD_LIBTIFF_FULL="$AD_DIR/$AD_LIBTIFF/$AD_LIBTIFF_DIR"

AD_LIBWEBP_DIR=libwebp-1.1.0
AD_LIBWEBP=libwebp
AD_LIBWEBP_FULL="$AD_DIR/$AD_LIBWEBP/$AD_LIBWEBP_DIR"

AD_GIFLIB_DIR=giflib-5.2.1
AD_GIFLIB=giflib
AD_GIFLIB_FULL="$AD_DIR/$AD_GIFLIB/$AD_GIFLIB_DIR"

AD_FREETYPE_DIR=freetype-2.10.1
AD_FREETYPE=freetype
AD_FREETYPE_FULL="$AD_DIR/$AD_FREETYPE/$AD_FREETYPE_DIR"

AD_BZIP_DIR=bzip2-1.0.6
AD_BZIP=bzip2
AD_BZIP_FULL="$AD_DIR/$AD_BZIP/$AD_BZIP_DIR"

AD_LIBBPG_DIR=libbpg-0.9.8
AD_LIBBPG=libbpg
AD_LIBBPG_FULL="$AD_DIR/$AD_LIBBPG/$AD_LIBBPG_DIR"

#AD_JBIGKIT=$AD_DIR/

AD_SDL2_DIR=SDL2-2.0.10
AD_SDL2=SDL
AD_SDL2_FULL="$AD_DIR/$AD_SDL2/$AD_SDL2_DIR"

AD_SDL2_IMAGE_DIR=SDL2_image-2.0.5
AD_SDL2_IMAGE=SDL
AD_SDL2_IMAGE_FULL="$AD_DIR/$AD_SDL2_IMAGE/$AD_SDL2_IMAGE_DIR"

AD_SDL2_TTF_DIR=SDL2_ttf-2.0.15
AD_SDL2_TTF=SDL
AD_SDL2_TTF_FULL="$AD_DIR/$AD_SDL2_TTF/$AD_SDL2_TTF_DIR"

AD_SDL2_NET_DIR=SDL2_net-2.0.1
AD_SDL2_NET=SDL
AD_SDL2_NET_FULL="$AD_DIR/$AD_SDL2_NET/$AD_SDL2_NET_DIR"

AD_GLEW_DIR=glew-2.1.0
AD_GLEW=glew
AD_GLEW_FULL="$AD_DIR/$AD_GLEW/$AD_GLEW_DIR"

#http://blog.httrack.com/blog/2014/03/09/what-are-your-gcc-flags/
AD_CFLAGS="-D_FILE_OFFSET_BITS=64 -Wall -O2 -fomit-frame-pointer "
#-O2 -funroll-loops
AD_CFLAGS_DEBUG="-D_FILE_OFFSET_BITS=64 -Wall -g"

AD_LDFLAGS=""

AD_LDFLAGS_DEBUG=""
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
    AD_WINDRES="translate.sh windres.exe"
    AD_DLLTOOL="translate.sh dlltool.exe"
    AD_RANLIB="translate.sh ranlib.exe"
    AD_NASM="translate.sh nasm.exe"
    AD_CFLAGS_DEBUG="$AD_CFLAGS_DEBUG -Og"
    #AD_MAKE="mingw32-make.exe"
    
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
  AD_CFLAGS="/nologo /MD /W3 /O2 /Oy-"
  AD_CFLAGS_DEBUG="/nologo /Od /MDd /W3 /Z7"
  AD_LDFLAGS="/nologo"
  AD_LDFLAGS_DEBUG="/nologo /debug"
  AD_MAKE=nmake.exe
  AD_AS=ml.exe
  
  if [ "$AD_ARCH" = "x64" ] 
  then
     AD_AS=ml64.exe
  fi
  
  export PATH="$PATH:$BASEDIR"
    echo "PATH: $PATH"
fi

echo "OS: $AD_OS"

if [ "$AD_OS" = "macos" ]
then
  AD_CFLAGS="$AD_CFLAGS -mmacosx-version-min=10.9"
  AD_CFLAGS_DEBUG="$AD_CFLAGS_DEBUG -mmacosx-version-min=10.9"
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
    
    mkdir -p "$AD_DIR/$1/$2/build/$3"
    
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
	    TCFLAGS=$AD_CFLAGS
      TLDFLAGS=$AD_LDFLAGS
      
      if [ $3 = "x86" ]; then
        TPLATFORM=Win32
        TCFLAGS="$TCFLAGS /DASMV /DASMINF /I."
        TLOC="/DASMV /DASMINF /I."
        TOBJA="inffas32.obj match686.obj"
      fi
	    if [ $3 = "x64" ]; then
        TCFLAGS="$TCFLAGS /DASMV /DASMINF /I."
        TLOC="/DASMV /DASMINF /I."
        TOBJA="inffasx64.obj gvmat64.obj inffas8664.obj"
      fi
	
      if [ $4 = "debug" ]; then
        TCONFIG="Debug"
		    TCFLAGS=$AD_CFLAGS_DEBUG
		    TLDFLAGS=$AD_LDFLAGS_DEBUG
        TLOC=""
        TOBJA=""
      fi
      
      StartBuild $AD_ZLIB $AD_ZLIB_DIR $1
      
      #copy vsproject
      #cp $BASEDIR/thirdparty/$AD_ZLIB/zlibstat.vcxproj_14 $AD_DIR/$AD_ZLIB/zlibstat.vcxproj
      #cp $BASEDIR/thirdparty/$AD_ZLIB/zlibvc.vcxproj_14 $AD_DIR/$AD_ZLIB/zlibvc.vcxproj
      
      #translate.sh MSBuild.exe $AD_ZLIB_FULL/contrib/vstudio/vc14/zlibvc.sln /p:Configuration="$TCONFIG" /p:Platform="$TPLATFORM"

	    $AD_MAKE -f win32/Makefile.msc /E "CFLAGS=$TCFLAGS" "LDFLAGS=$TLDFLAGS" AS="$AD_AS" LOC="$TLOC." OBJA="$TOBJA"
	    
      test -d "build/$1/lib" || mkdir -p "build/$1/lib"
      cp zlib1.dll build/$1/lib/zlib1.dll
      cp zlib.lib build/$1/lib/zlib.lib
      cp zdll.lib build/$1/lib/zdll.lib
      
      #TSTATFOLDER=ZlibStatRelease
      #TDLLFOLDER=ZlibDllRelease
      #if [ $4 == "debug" ] || [ $4 == "debug-static" ] || [ $4 == "debug-shared" ]; then
      #  TSTATFOLDER=ZlibStatDebug
      #  TDLLFOLDER=ZlibDllDebug
      #fi
      
      #copy build
      #test -d "$AD_ZLIB_FULL/build/$1" || mkdir -p "$AD_ZLIB_FULL/build/$1" && cp -a $AD_ZLIB_FULL/contrib/vstudio/vc14/$TPLATFORM/$TSTATFOLDER "$AD_ZLIB_FULL/build/$1"
      #test -d "$AD_ZLIB_FULL/build/$1" || mkdir -p "$AD_ZLIB_FULL/build/$1" && cp -a $AD_ZLIB_FULL/contrib/vstudio/vc14/$TPLATFORM/ $TDLLFOLDER "$AD_ZLIB_FULL/build/$1"
      
      EndBuild $AD_ZLIB $AD_ZLIB_DIR $1
      
    else
      echo COMPILE GCC
      STATIC=""
      if [ $2 = "static" ]; then
        STATIC="--static"
      fi
      
      TCFLAGS=$AD_CFLAGS
      if [ $4 = "debug" ]; then
        TCFLAGS=$AD_CFLAGS_DEBUG
      fi
      
      StartBuild $AD_ZLIB $AD_ZLIB_DIR $1
      
      CONFIG_OPT=""
      if [ $AD_COMPILER = "mingw" ]; then
        STATIC="SHARED_MODE=0"
        if [ $2 = "shared" ]; then
          STATIC="SHARED_MODE=1"
        fi
        
        
        echo Make
        $AD_MAKE "-f$AD_ZLIB_FULL/win32/Makefile.gcc" CFLAGS="$TCFLAGS" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" AS="$AD_AS" STRIP="$AD_STRIP" RC="$AD_RC" -j"$AD_THREADS"
        CheckStatus "Zlib"
        $AD_MAKE "-fwin32/Makefile.gcc" install DESTDIR="$AD_ZLIB_FULL/build/$1" "$STATIC"
        
      else

        CC="$AD_CC" $AD_ZLIB_FULL/./configure $STATIC --prefix=$AD_ZLIB_FULL/build/$1 --eprefix=$AD_ZLIB_FULL/build/$1 $CONFIG_OPT
      
        CheckStatus "Zlib"
        echo Make
        $AD_MAKE CFLAGS="$TCFLAGS" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" -j"$AD_THREADS" LD="$AD_CC"
        CheckStatus "Zlib"
        $AD_MAKE install
      
      fi
      
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
      TFLAGS=""
      if [ "$AD_COMPILER" = "mingw" ]
      then
        TFLAGS="$FLAGS --host=mingw32"
      fi
      
      TCFLAGS=$AD_CFLAGS
      if [ "$4" = "debug" ]; then
        TCFLAGS=$AD_CFLAGS_DEBUG
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
      
      T_AR="AR=$AD_AR"
      if [ AD_OS="macos" ]
      then
        T_AR=""
      fi
      
      #  
      $AD_LIBPNG_FULL/./configure CFLAGS="$TCFLAGS" "$SSE" "$SHARED" "$STATIC" LDFLAGS=-L$AD_ZLIB_FULL/build/$1/lib --prefix=$AD_LIBPNG_FULL/build/$1 --exec-prefix=$AD_LIBPNG_FULL/build/$1 CPPFLAGS="-I$AD_ZLIB_FULL/build/$1/include" $TFLAGS CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB"
      
      
      
      CheckStatus "libpng"
      #CC="$AD_CC" CXX="$AD_CXX"
      $AD_MAKE -j"$AD_THREADS"

      #mingw has error compiling so needs to correct pnglibconf.h
      #THen retry building
      if [ "$AD_COMPILER" = "mingw" ]
      then
      
        if cd .deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../
        fi
        
        if cd contrib/libtests/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../../
        fi
        
        
        if cd contrib/tools/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../../
        fi
        
        if cd intel/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../
        fi
        
        if cd mips/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../
        fi
        
        if cd powerpc/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../
        fi
        #rename windows files to unix in .dep foler
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
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../
        fi
        
        if cd contrib/libtests/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../../
        fi
        
        
        if cd contrib/tools/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../../
        fi
        
        if cd intel/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../
        fi
        
        if cd mips/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../
        fi
        
        if cd powerpc/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
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
      
      #copy include files since mingw cant seem to follow junctions
      if [ "$AD_COMPILER" = "mingw" ]
      then
        rm $AD_LIBPNG_FULL/build/$1/include/png.h
        cp $AD_LIBPNG_FULL/build/$1/include/libpng16/png.h $AD_LIBPNG_FULL/build/$1/include
        rm $AD_LIBPNG_FULL/build/$1/include/pngconf.h
        cp $AD_LIBPNG_FULL/build/$1/include/libpng16/pngconf.h $AD_LIBPNG_FULL/build/$1/include
        rm $AD_LIBPNG_FULL/build/$1/include/pnglibconf.h
        cp $AD_LIBPNG_FULL/build/$1/include/libpng16/pnglibconf.h $AD_LIBPNG_FULL/build/$1/include
        
        rm $AD_LIBPNG_FULL/build/$1/lib/libpng.a
        rm $AD_LIBPNG_FULL/build/$1/lib/libpng.la
        cp $AD_LIBPNG_FULL/build/$1/lib/libpng16.a $AD_LIBPNG_FULL/build/$1/lib/libpng.a
        cp $AD_LIBPNG_FULL/build/$1/lib/libpng16.la $AD_LIBPNG_FULL/build/$1/lib/libpng.la
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
    
    T_AR="AR=$AD_AR"
    if [ AD_OS="macos" ]
    then
      T_AR=""
    fi
    
    StartBuild $AD_LIBJPG $AD_LIBJPG_DIR $1
    
    $AD_LIBJPG_FULL/./configure CFLAGS="$CFLAGS" "$SHARED" --prefix=$AD_LIBJPG_FULL/build/$1 --exec-prefix=$AD_LIBJPG_FULL/build/$1 CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB"
    CheckStatus "libjpeg"
    $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
    CheckStatus "libjpeg"
    
    if [ "$AD_COMPILER" = "mingw" ]
    then
      #rename windows files to unix in .dep foler
      if cd .deps ; then
        sed -i -- 's/D:/\/mnt\/d/g' *
        cd ../
      fi
    fi
    $AD_MAKE install
    EndBuild $AD_LIBJPG $AD_LIBJPG_DIR $1

  fi
}

BuildLibjpegturbo()
{
  if [ $5 = "free" ]; then
  
    echo building turbo libjpeg
    
    if [ "$AD_COMPILER" == "msvc" ]
    then
    
      StartBuild $AD_LIBJPGTURBO $AD_LIBJPGTURBO_DIR $1
      
      EndBuild $AD_LIBJPGTURBO
    else

      StartBuild $AD_LIBJPGTURBO $AD_LIBJPGTURBO_DIR $1
      #cmake -G"Unix Makefiles" [additional CMake flags] {source_directory}
      #make
      #cd "$AD_LIBJPGTURBO_FULL/build/$1"
      
      if [ "$4" = "debug" ]; then
        cmake -G"Unix Makefiles" -DWITH_JPEG8=1 -DCMAKE_INSTALL_PREFIX="$AD_LIBJPGTURBO_FULL/build/$1" -DCMAKE_BUILD_TYPE=Debug
      else
        cmake -G"Unix Makefiles" -DWITH_JPEG8=1 -DCMAKE_INSTALL_PREFIX="$AD_LIBJPGTURBO_FULL/build/$1"
      fi
      
      make
      make install
       
      #../../../../../

      #cd "$AD_LIBJPGTURBO_FULL"
      
      EndBuild $AD_LIBJPGTURBO $AD_LIBJPGTURBO_DIR $1
    fi
    
  fi
}

#old method to build turbo before it moved to cmake
BuildLibjpegturboAutoreconf()
{
  if [ $5 = "free" ]; then
  
    echo building turbo libjpeg
    
    if [ "$AD_COMPILER" == "msvc" ]
    then
    
      StartBuild $AD_LIBJPGTURBO $AD_LIBJPGTURBO_DIR $1
      
      EndBuild $AD_LIBJPGTURBO
    else
    
      StartBuild $AD_LIBJPGTURBO $AD_LIBJPGTURBO_DIR $1
      
      TCFLAGS=$AD_CFLAGS
      if [ "$4" = "debug" ]; then
        TCFLAGS=$AD_CFLAGS_DEBUG
      fi
      
      TFLAGS=""
      if [ "$AD_COMPILER" = "mingw" ]
      then
        echo Arch "$3"
        if [ "$3" = "x64" ]
        then
          TFLAGS=--host=x86_64-w64-mingw32
        else
          TFLAGS=--host=i686-w64-mingw32
        fi
      fi
      
      TSTATIC="--disable-static"
      TSHARED="--disable-shared"
      if [ $2 = "static" ]; then
        TSTATIC="--enable-static"
      else
        TSHARED="--enable-shared"
      fi
      
      T_AR="AR=$AD_AR"
      if [ AD_OS="macos" ]
      then
        T_AR=""
      fi
      
      StartBuild $AD_LIBJPGTURBO $AD_LIBJPGTURBO_DIR $1
      
      
      autoreconf -f -i
      
      
      $AD_LIBJPGTURBO_FULL/./configure CFLAGS="$TCFLAGS" "$TSHARED" "$TSTATIC" --prefix=$AD_LIBJPGTURBO_FULL/build/$1 --exec-prefix=$AD_LIBJPGTURBO_FULL/build/$1 $TFLAGS CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" NASM="$AD_NASM"
      
      
      CheckStatus "turbo libjpeg"
      $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
      
      CheckStatus "turbo libjpeg"
      
      if [ "$AD_COMPILER" = "mingw" ]
      then
        #rename windows files to unix in .dep foler
        if cd .deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../
        fi
        if cd simd/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../
        fi
        if cd md5/.deps ; then
          sed -i -- 's/D:/\/mnt\/d/g' *
          cd ../../
        fi
      fi
      
      $AD_MAKE install V=1
      EndBuild $AD_LIBJPGTURBO $AD_LIBJPGTURBO_DIR $1
      
    fi
    
  fi
}

#LZMA
#public domain
#https://tukaani.org/xz/
BuildXz()
{
  
  if [ $5 = "free" ]; then
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
    
    TCFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      TCFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    TFLAGS=""
    TOPTIONS=""
    if [ "$AD_COMPILER" = "mingw" ]
    then
      echo Arch "$3"
      if [ "$3" = "x64" ]
      then
        TFLAGS="--host=x86_64-w64-mingw32"
      else
        TFLAGS="--host=i686-w64-mingw32"
      fi
      #todo fix threads=posix or yes crashing build complaining about undefined sigfillset
      TOPTIONS="--enable-threads=vista --disable-scripts --disable-nls"
    fi
    
    TSTATIC="--disable-static"
    TSHARED="--disable-shared"
    if [ $2 = "static" ]; then
      TSTATIC="--enable-static"
    else
      TSHARED="--enable-shared"
    fi
    
    T_AR="AR=$AD_AR"
    if [ AD_OS="macos" ]
    then
      T_AR=""
    fi

    StartBuild $AD_XZ $AD_XZ_DIR $1
    
    touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
    #need to set posix to avoid undefinde sigset when trying with posix threads in mingw
    #-D_POSIX
    $AD_XZ_FULL/./configure CFLAGS="$TCFLAGS -std=c11" "$TSHARED" "$TSTATIC" $TOPTIONS --prefix="$AD_XZ_FULL/build/$1" --exec-prefix="$AD_XZ_FULL/build/$1" CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB"
    CheckStatus "xz"
    $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
    CheckStatus "xz"
    if [ "$AD_COMPILER" = "mingw" ]
    then
      #rename windows files to unix in .dep foler
      if cd src/liblzma/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
      if cd src/xzdec/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
      if cd src/xz/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
      if cd src/lzmainfo/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
    fi
    
    $AD_MAKE install
    EndBuild $AD_XZ $AD_XZ_DIR $1

    #CC="$AD_CC" CXX="$AD_CXX"
  fi

}

#permissive
#http://www.simplesystems.org/libtiff/
#requires xz, zlib, libjpg
BuildLibtiff()
{
  if [ $5 = "free" ]; then
  
    echo "Building libtiff"
    
    TCFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      TCFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    TFLAGS=""
    TOPTIONS=""
    if [ "$AD_COMPILER" = "mingw" ]
    then
      echo Arch "$3"
      if [ "$3" = "x64" ]
      then
        TFLAGS="--host=x86_64-w64-mingw32"
      else
        TFLAGS="--host=i686-w64-mingw32"
      fi

    fi
    
    TSTATIC="--disable-static"
    TSHARED="--disable-shared"
    if [ $2 = "static" ]; then
      TSTATIC="--enable-static"
    else
      TSHARED="--enable-shared"
    fi
    
    T_AR="AR=$AD_AR"
    if [ AD_OS="macos" ]
    then
      T_AR=""
    fi
    
    #libtiff already has build folder with contents. these will get moved back
    #rm $AD_LIBTIFF_FULL/build/CMakeLists.txt
    #rm $AD_LIBTIFF_FULL/build/Makefile.am
    #rm $AD_LIBTIFF_FULL/build/Makefile.in
    #rm $AD_LIBTIFF_FULL/build/README
    #rm $AD_LIBTIFF_FULL/build/Makefile
    
    StartBuild $AD_LIBTIFF $AD_LIBTIFF_DIR $1
    
    $AD_LIBTIFF_FULL/./configure CFLAGS="$TCFLAGS" $TSHARED $TSTATIC $TFLAGS --with-zlib-include-dir=$AD_ZLIB_FULL/build/$1/include --with-zlib-lib-dir=$AD_ZLIB_FULL/build/$1/lib --with-jpeg-include-dir=$AD_LIBJPGTURBO_FULL/build/$1/include --with-jpeg-lib-dir=$AD_LIBJPGTURBO_FULL/build/$1/lib --with-lzma-include-dir=$AD_XZ_FULL/build/$1/include --with-lzma-lib-dir=$AD_XZ_FULL/build/$1/lib  --prefix=$AD_LIBTIFF_FULL/build/$1 --exec-prefix=$AD_LIBTIFF_FULL/build/$1 CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB"
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
    
    if [ "$AD_COMPILER" = "mingw" ]
    then
      #rename windows files to unix in .dep foler
      if cd libtiff/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../
      fi
      if cd tools/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../
      fi
      if cd  contrib/addtiffo/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
      if cd  contrib/dbs/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
      if cd  contrib/iptcutil/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
    fi
    
    
    $AD_MAKE install
    CheckStatus "libtiff"
    
    mv $BASEDIR/thirdparty/$AD_LIBTIFF/$AD_LIBTIFF_DIR/build/CMakeLists.txt $BASEDIR/temp
    mv $BASEDIR/thirdparty/$AD_LIBTIFF/$AD_LIBTIFF_DIR/build/Makefile.am $BASEDIR/temp
    mv $BASEDIR/thirdparty/$AD_LIBTIFF/$AD_LIBTIFF_DIR/build/Makefile.in $BASEDIR/temp
    mv $BASEDIR/thirdparty/$AD_LIBTIFF/$AD_LIBTIFF_DIR/build/README $BASEDIR/temp
    
    
    EndBuild $AD_LIBTIFF $AD_LIBTIFF_DIR $1
    
    mv $BASEDIR/temp/CMakeLists.txt $BASEDIR/thirdparty/$AD_LIBTIFF/$AD_LIBTIFF_DIR/build
    mv $BASEDIR/temp/Makefile.am $BASEDIR/thirdparty/$AD_LIBTIFF/$AD_LIBTIFF_DIR/build
    mv $BASEDIR/temp/Makefile.in $BASEDIR/thirdparty/$AD_LIBTIFF/$AD_LIBTIFF_DIR/build
    mv $BASEDIR/temp/README $BASEDIR/thirdparty/$AD_LIBTIFF/$AD_LIBTIFF_DIR/build
    
  fi
}

#permissive
#http://giflib.sourceforge.net/
BuildGiflib()
{
  if [ $5 = "free" ]; then
  
    echo "Building giflib"
    
    TCFLAGS="$AD_CFLAGS -fPIC"
    if [ "$4" = "debug" ]; then
      TCFLAGS="$AD_CFLAGS_DEBUG -fPIC"
    fi
    
    TFLAGS=""
    TOPTIONS=""
    if [ "$AD_COMPILER" = "mingw" ]
    then
      echo Arch "$3"
      if [ "$3" = "x64" ]
      then
        TFLAGS="--host=x86_64-w64-mingw32"
      else
        TFLAGS="--host=i686-w64-mingw32"
      fi

    fi
    
    TSTATIC="--disable-static"
    TSHARED="--disable-shared"
    if [ $2 = "static" ]; then
      TSTATIC="--enable-static"
    else
      TSHARED="--enable-shared"
    fi
    
    T_AR="AR=$AD_AR"
    if [ AD_OS="macos" ]
    then
      T_AR=""
    fi
    
    StartBuild $AD_GIFLIB $AD_GIFLIB_DIR $1
    
    touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
    #autoreconf -f -i
    
    chmod +x $AD_GIFLIB_FULL/configure
    
    #$AD_GIFLIB_FULL/./configure CFLAGS="$TCFLAGS" $TSHARED $TSTATIC $TFLAGS --prefix=$AD_GIFLIB_FULL/build/$1 --exec-prefix=$AD_GIFLIB_FULL/build/$1 CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB"
    
    CheckStatus "giflib"
    
    #--exec-prefix=$AD_GIFLIB_FULL/build/$1 $TSHARED $TSTATIC
    $AD_MAKE CFLAGS="$TCFLAGS" $TFLAGS PREFIX="$AD_GIFLIB_FULL/build/$1" CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" -j"$AD_THREADS"
    
    CheckStatus "giflib"
    
    if [ "$AD_COMPILER" = "mingw" ]
    then
      #rename windows files to unix in .dep foler
      if cd lib/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../
      fi
      if cd util/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../
      fi
    fi
    
    $AD_MAKE install PREFIX="$AD_GIFLIB_FULL/build/$1"
    CheckStatus "giflib"
    
    EndBuild $AD_GIFLIB $AD_GIFLIB_DIR $1
  
  fi
}

#permissive
#$AD_LIBWEBP/./autogen.sh
#requires giblib libjpeg libtiff
BuildLibwebp()
{

  if [ $5 = "free" ]; then
  
    echo "Building libwebp"
    
    TCFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      TCFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    TFLAGS=""
    TOPTIONS=""
    if [ "$AD_COMPILER" = "mingw" ]
    then
      echo Arch "$3"
      if [ "$3" = "x64" ]
      then
        TFLAGS="--host=x86_64-w64-mingw32"
      else
        TFLAGS="--host=i686-w64-mingw32"
      fi

    fi
    
    TSTATIC="--disable-static"
    TSHARED="--disable-shared"
    if [ $2 = "static" ]; then
      TSTATIC="--enable-static"
    else
      TSHARED="--enable-shared"
    fi
    
    T_AR="AR=$AD_AR"
    if [ AD_OS="macos" ]
    then
      T_AR=""
    fi
    
    echo "Webp: $AD_LIBWEBP_FULL/build/$1"
    
    StartBuild $AD_LIBWEBP $AD_LIBWEBP_DIR $1
    
    ./autogen.sh
    
    $AD_LIBWEBP_FULL/./configure CFLAGS="$TCFLAGS" $TSHARED $TSTATIC $TFLAGS --enable-png --with-jpegincludedir=$AD_LIBJPGTURBO_FULL/build/$1/include --with-jpeglibdir=$AD_LIBJPGTURBO_FULL/build/$1/lib --with-tiffincludedir=$AD_LIBTIFF_FULL/build/$1/include --with-tifflibdir=$AD_LIBTIFF_FULL/build/$1/lib --with-gifincludedir=$AD_GIFLIB_FULL/build/$1/include  --with-giflibdir=$AD_GIFLIB_FULL/build/$1/lib --with-pngincludedir=$AD_LIBPNG_FULL/build/$1/include --with-pnglibdir=$AD_LIBPNG_FULL/build/$1/lib --prefix=$AD_LIBWEBP_FULL/build/$1 --exec-prefix=$AD_LIBWEBP_FULL/build/$1 LDFLAGS="-L$AD_LIBPNG_FULL/build/$1/lib -L$AD_ZLIB_FULL/build/$1/lib -L$AD_GIFLIB_FULL/build/$1/lib" LIBS="-lm -lpng -lgif -lz" CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB"
    CheckStatus "libwebp"
    
    $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
    CheckStatus "libwebp"
    
    if [ "$AD_COMPILER" = "mingw" ]
    then
      #rename windows files to unix in .dep foler
      if cd src/dec/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
      if cd src/enc/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
      if cd src/dsp/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
      if cd src/utils/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../../
      fi
      if cd imageio/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../
      fi
      if cd examples/.deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../../
      fi
    fi
    
    $AD_MAKE install
    CheckStatus "libwebp"
    
    EndBuild $AD_LIBWEBP $AD_LIBWEBP_DIR $1
  
  fi
}

#bzip make install fails for mingw as it assumes names without .exe
#this copies install but adds .exe
InstallBzip()
{
  if ( test ! -d $1/bin ) ; then mkdir -p $1/bin ; fi
	if ( test ! -d $1/lib ) ; then mkdir -p $1/lib ; fi
	if ( test ! -d $1/man ) ; then mkdir -p $1/man ; fi
	if ( test ! -d $1/man/man1 ) ; then mkdir -p $1/man/man1 ; fi
	if ( test ! -d $1/include ) ; then mkdir -p $1/include ; fi
	cp -f bzip2.exe $1/bin/bzip2.exe
	cp -f bzip2.exe $1/bin/bunzip2.exe
	cp -f bzip2.exe $1/bin/bzcat.exe
	cp -f bzip2recover.exe $1/bin/bzip2recover.exe
	chmod a+x $1/bin/bzip2.exe
	chmod a+x $1/bin/bunzip2.exe
	chmod a+x $1/bin/bzcat.exe
	chmod a+x $1/bin/bzip2recover.exe
	cp -f bzip2.1 $1/man/man1
	chmod a+r $1/man/man1/bzip2.1
	cp -f bzlib.h $1/include
	chmod a+r $1/include/bzlib.h
	cp -f libbz2.a $1/lib
	chmod a+r $1/lib/libbz2.a
	cp -f bzgrep.exe $1/bin/bzgrep.exe
	ln -s -f $1/bin/bzgrep.exe $1/bin/bzegrep.exe
	ln -s -f $1/bin/bzgrep.exe $1/bin/bzfgrep.exe
	chmod a+x $1/bin/bzgrep.exe
	cp -f bzmore.exe $1/bin/bzmore.exe
	ln -s -f $1/bin/bzmore.exe $1/bin/bzless.exe
	chmod a+x $1/bin/bzmore.exe
	cp -f bzdiff.exe $1/bin/bzdiff.exe
	ln -s -f $1/bin/bzdiff.exe $1/bin/bzcmp.exe
	chmod a+x $1/bin/bzdiff.exe
	cp -f bzgrep.1 bzmore.1 bzdiff.1 $1/man/man1
	chmod a+r $1/man/man1/bzgrep.1
	chmod a+r $1/man/man1/bzmore.1
	chmod a+r $1/man/man1/bzdiff.1
  echo ".so man1/bzgrep.1" > $1/man/man1/bzegrep.1
	echo ".so man1/bzgrep.1" > $1/man/man1/bzfgrep.1
	echo ".so man1/bzmore.1" > $1/man/man1/bzless.1
	echo ".so man1/bzdiff.1" > $1/man/man1/bzcmp.1
}

#permissive
#http://www.bzip.org/
BuildBzip()
{
  if [ $5 = "free" ]; then
    echo "Building bzip2"

    StartBuild $AD_BZIP $AD_BZIP_DIR $1

    TCFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      TCFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    T_AR="AR=$AD_AR"
    if [ AD_OS="macos" ]
    then
      T_AR=""
    fi

    #test fails for mingw in maikefile since if tries to find ./bzip2 rather than bzip2.exe
    #hence we skip the test for mingw
    if [ "$AD_COMPILER" = "mingw" ]
    then
      #libbz2.a bzip2 bzip2recover
      $AD_MAKE libbz2.a CFLAGS="$TCFLAGS" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" -j"$AD_THREADS"
      $AD_MAKE bzip2 CFLAGS="$TCFLAGS" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" -j"$AD_THREADS"
      $AD_MAKE bzip2recover CFLAGS="$TCFLAGS" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" -j"$AD_THREADS"
      
      CheckStatus "bzip2"
      
      InstallBzip $AD_BZIP_FULL/build/$1
    else
      $AD_MAKE CFLAGS="$TCFLAGS" CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" -j"$AD_THREADS"
      
      CheckStatus "bzip2"
      $AD_MAKE install CFLAGS="$TCFLAGS" PREFIX=$AD_BZIP_FULL/build/$1 CC="$AD_CC"
    fi
    
    
    
    EndBuild $AD_BZIP $AD_BZIP_DIR $1
  fi
}

#permissive with advertising
#https://freetype.org/index.html
#requires zlib, libpng, bzip2, harfbuzz(currently disabled)
BuildFreetype()
{
  if [ $5 = "free" ]; then
    echo "Building Freetype"
    
    TCFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      TCFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    TFLAGS=""
    TOPTIONS=""
    if [ "$AD_COMPILER" = "mingw" ]
    then
      echo Arch "$3"
      if [ "$3" = "x64" ]
      then
        TFLAGS="--host=x86_64-w64-mingw32"
      else
        TFLAGS="--host=i686-w64-mingw32"
      fi

    fi
    
    TSTATIC="--disable-static"
    TSHARED="--disable-shared"
    if [ $2 = "static" ]; then
      TSTATIC="--enable-static"
    else
      TSHARED="--enable-shared"
    fi
    
    T_AR="AR=$AD_AR"
    if [ AD_OS="macos" ]
    then
      T_AR=""
    fi
    
    StartBuild $AD_FREETYPE $AD_FREETYPE_DIR $1
    
    if [ "$AD_COMPILER" = "mingw" ]
    then
      sed -i 's/(SEP),$(APINAMES_EXE)/(SEP),translate.sh objs\/apinames.exe/' $AD_FREETYPE_FULL/builds/exports.mk

    fi
    
    #
    $AD_FREETYPE_FULL/./configure CFLAGS="$TCFLAGS" $TSHARED $TSTATIC $TFLAGS --prefix=$AD_FREETYPE_FULL/build/$1 --exec-prefix=$AD_FREETYPE_FULL/build/$1 ZLIB_CFLAGS=-I$AD_ZLIB_FULL/build/$1/include ZLIB_LIBS=$AD_ZLIB_FULL/build/$1 BZIP2_CFLAGS=-I$AD_BZIP_FULL/build/$1/include BZIP2_LIBS=$AD_BZIP_FULL/build/$1/lib LIBPNG_CFLAGS=-I$AD_LIBPNG_FULL/build/$1/include LIBPNG_LIBS=$AD_LIBPNG_FULL/build/$1 --with-harfbuzz=no CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB"
    #removed rc since not compiling on ubuntu 18.04
    #RC="$AD_RC"
    CheckStatus "Freetype"
    
    #Adding cc and cxx here causes freetype to not compile
    $AD_MAKE -j"$AD_THREADS"
    CheckStatus "Freetype"
    $AD_MAKE install
    EndBuild $AD_FREETYPE $AD_FREETYPE_DIR $1
  fi
}



#combiniation of lgpl and gpl
#depends on libpng, zlib, sdl
BuildLibbpg()
{
  
  echo "Building libbpg"
  StartBuild $AD_LIBBPG $AD_LIBBPG_DIR $1
  cd $AD_LIBBPG_FULL
  echo "$AD_LIBPNG_FULL/build/$1/lib"
  C_INCLUDE_PATH="$C_INCLUDE_PATH:$AD_LIBPNG_FULL/build/$1/include:$AD_LIBJPGTURBO_FULL/build/$1/include" LIBRARY_PATH="$LIBRARY_PATH:$AD_LIBPNG_FULL/build/$1/lib:$AD_ZLIB_FULL/build/$1/lib:$AD_LIBJPGTURBO_FULL/build/$1/lib" $AD_MAKE CONFIG_APPLE=y prefix="build/$1" LIBS=-lz -j"$AD_THREADS" CC="$AD_CC" CXX="$AD_CXX" $T_AR AS="$AD_AS" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB"
  CheckStatus "libbpg"
  $AD_MAKE install
  cd $BASEDIR/temp
  EndBuild $AD_LIBBPG $AD_LIBBPG_DIR $1
}



#permissive
#
BuildSdl2()
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
      
      TFLAGS=""
      if [ "$AD_COMPILER" = "mingw" ]
      then
        echo Arch "$3"
        if [ "$3" = "x64" ]
        then
          TFLAGS=--host=x86_64-w64-mingw32
        else
          TFLAGS=--host=i686-w64-mingw32
        fi
      fi
      
      TSTATIC="--disable-static"
      TSHARED="--disable-shared"
      if [ "$2" = "static" ]; then
        TSTATIC="--enable-static"
      else
        TSHARED="--enable-shared"
      fi
      
      T_AR="AR=$AD_AR"
      if [ AD_OS="macos" ]
      then
        T_AR=""
      fi
      
      T_VULKAN=""
      if [ AD_OS="linux" ]
      then
        T_VULKAN="--enable-video-vulkan"
      fi
      
      $AD_SDL2_FULL/./configure CFLAGS="$TCFLAGS" --enable-sse2 --enable-sse3 $TSTATIC $TSHARED --prefix=$AD_SDL2_FULL/build/$1 --exec-prefix=$AD_SDL2_FULL/build/$1 $TFLAGS CC="$AD_CC" CXX="$AD_CXX" LD="$AD_LD" $T_AR AS="$AD_AS" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" WINDRES="$AD_WINDRES" $T_VULKAN
      CheckStatus "SDL2"
      #ALSA or esd may be needed on linux for sound
      #--with-alsa-prefix=PFX  Prefix where Alsa library is installed(optional)
      #--with-alsa-inc-prefix=PFX  Prefix where include libraries are (optional)
      #--with-esd-prefix=PFX   Prefix where ESD is installed (optional)
      #--with-esd-exec-prefix=PFX Exec prefix where ESD is installed (optional)

      $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" LD="$AD_LD" $T_AR AS="$AD_AS" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" WINDRES="$AD_WINDRES" -j"$AD_THREADS" V=1

      CheckStatus "SDL2"
      
      if [ "$AD_COMPILER" = "mingw" ]
      then
        #rename windows files to unix in .dep foler
        if cd build ; then
          find . -type f -a \( -name "*.d" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
          cd ../
        fi
      fi
      
      $AD_MAKE install V=1
      #DESTDIR="$AD_SDL2_FULL/build/$1"
      EndBuild $AD_SDL2 $AD_SDL2_DIR $1
    
    fi
  fi
}

#permissive
#compile error in config https://github.com/Linuxbrew/legacy-linuxbrew/issues/172
#seems to use sdl lib location for webp
#depends jpeg(turbo) zlib, xz, libtiff, webp
BuildSdl2Image()
{
  if [ $5 = "free" ]; then
    echo "Building SDL2_image"
    
    if [ "$AD_COMPILER" == "msvc" ]
    then
      StartBuild $AD_SDL2_IMAGE $AD_SDL2_IMAGE_DIR $1
      EndBuild $AD_SDL2_IMAGE $AD_SDL2_IMAGE_DIR $1
    else
      
      TCFLAGS=$AD_CFLAGS
      if [ "$4" = "debug" ]; then
        TCFLAGS=$AD_CFLAGS_DEBUG
      fi
      
      TSTATIC="--disable-static"
      TSHARED="--disable-shared"
      if [ "$2" = "static" ]; then
        TSTATIC="--enable-static"
      else
        TSHARED="--enable-shared"
      fi
      
      StartBuild $AD_SDL2_IMAGE $AD_SDL2_IMAGE_DIR $1
      
      if [ $AD_OS = "macos" ]
      then
          $AD_SDL2_IMAGE_FULL/./configure CFLAGS="$TCFLAGS" $TSTATIC $TSHARED --prefix=$AD_SDL2_IMAGE_FULL/build/$1 --exec-prefix=$AD_SDL2_IMAGE_FULL/build/$1 SDL_CFLAGS=-I$AD_SDL2_FULL/build/$1/include/SDL2 SDL_LIBS=-L$AD_SDL2_FULL/build/$1/lib LIBPNG_CFLAGS=-I$AD_LIBPNG_FULL/build/$1/include LIBPNG_LIBS=-L$AD_LIBPNG_FULL/build/$1/lib LIBWEBP_CFLAGS=-I$AD_LIBWEBP_FULL/build/$1/include LIBWEBP_LIBS=-L$AD_LIBWEBP_FULL/build/$1/lib LDFLAGS="-L$AD_LIBWEBP_FULL/build/$1/lib -L$AD_LIBTIFF_FULL/build/$1/lib -L$AD_GIFLIB_FULL/build/$1/lib -L$AD_LIBJPGTURBO_FULL/build/$1/lib -L$AD_SDL2_FULL/build/$1/lib -L$AD_LIBPNG_FULL/build/$1/lib" CC="$AD_CC" CXX="$AD_CXX"
          CheckStatus "SDL2_image"
          $AD_MAKE LIBS="-lSDL2 -framework CoreVideo -framework CoreGraphics -framework ImageIO -framework CoreAudio -framework AudioToolbox -framework Foundation -framework CoreFoundation -framework CoreServices -framework OpenGL -framework ForceFeedback -framework IOKit -framework Cocoa -framework Carbon" CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
          CheckStatus "SDL2_image"

      else
      
        
        
        TLIBS=-lSDL2
        TFLAGS=""
        if [ "$AD_COMPILER" = "mingw" ]
        then
          echo Arch "$3"
          if [ "$3" = "x64" ]
          then
            TFLAGS=--host=x86_64-w64-mingw32
          else
            TFLAGS=--host=i686-w64-mingw32
          fi
          
          TLIBS="-lmingw32 $TLIBS -lSDL2main"
        fi
        
        
        
        touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
        
        #LIBS="-lSDL2 -llzma -lm"
        #Removed as as causes mingw compile to hang when first using libtool as it runs as.exe which does nothing with no input
        # AS="$AD_AS"
        #todo libpng does not seem to place /build/include
        $AD_SDL2_IMAGE_FULL/./configure CFLAGS="$TCFLAGS" $TSTATIC $TSHARED $TFLAGS --with-sdl-prefix=$AD_SDL2_FULL/build/$1 --with-sdl-exec-prefix=$AD_SDL2_FULL/build/$1 --prefix=$AD_SDL2_IMAGE_FULL/build/$1 --exec-prefix=$AD_SDL2_IMAGE_FULL/build/$1 SDL_CFLAGS=-I$AD_SDL2_FULL/build/$1/include/SDL2 SDL_LIBS=-L$AD_SDL2_FULL/build/$1/lib LIBPNG_CFLAGS=-I$AD_LIBPNG_FULL/build/$1/include LIBPNG_LIBS=-L$AD_LIBPNG_FULL/build/$1/lib LIBWEBP_CFLAGS=-I$AD_LIBWEBP_FULL/build/$1/include LIBWEBP_LIBS=-L$AD_LIBWEBP_FULL/build/$1/lib LDFLAGS="-L$AD_LIBWEBP_FULL/build/$1/lib -L$AD_LIBTIFF_FULL/build/$1/lib -L$AD_GIFLIB_FULL/build/$1/lib -L$AD_LIBJPGTURBO_FULL/build/$1/lib -L$AD_SDL2_FULL/build/$1/lib -L$AD_LIBPNG_FULL/build/$1/lib -L$AD_ZLIB_FULL/build/$1/lib -L$AD_XZ_FULL/build/$1/lib" CPPFLAGS="-I$AD_LIBWEBP_FULL/build/$1/include -I$AD_LIBTIFF_FULL/build/$1/include -I$AD_GIFLIB_FULL/build/$1/include -I$AD_LIBJPGTURBO_FULL/build/$1/include -I$AD_SDL2_FULL/build/$1/include -I$AD_LIBPNG_FULL/build/$1/include" LIBS="-lSDL2 -lz -llzma" CC="$AD_CC" CXX="$AD_CXX" LD="$AD_LD" AR="$AD_AR" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" WINDRES="$AD_WINDRES"
        CheckStatus "SDL2_image"
        
        $AD_MAKE LIBS="$TLIBS" CC="$AD_CC" CXX="$AD_CXX" LD="$AD_LD" AR="$AD_AR" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" WINDRES="$AD_WINDRES" -j"$AD_THREADS" V=1
        CheckStatus "SDL2_image"
        
        if [ "$AD_COMPILER" = "mingw" ]
        then
          #rename windows files to unix in .dep foler
          if cd .deps ; then
            find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
            cd ../
          fi
        fi


      fi
      make install V=1
      EndBuild $AD_SDL2_IMAGE $AD_SDL2_IMAGE_DIR $1
      
      
    fi
  fi 
}

#depends freetype
BuildSdl2Ttf()
{
  
  if [ $5 = "free" ]; then
    echo "Building SDL2_ttf"
    
    TCFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      TCFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    TLIBS=-lSDL2
    TFLAGS=""
    TOPTIONS=""
    if [ "$AD_COMPILER" = "mingw" ]
    then
      echo Arch "$3"
      if [ "$3" = "x64" ]
      then
        TFLAGS="--host=x86_64-w64-mingw32"
      else
        TFLAGS="--host=i686-w64-mingw32"
      fi
      TLIBS="-lmingw32 -lSDL2main $TLIBS -lm -ldinput8 -ldxguid -ldxerr8 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lversion -luuid -lfreetype -lbz2 -lpng -lz"
    fi
    
    TSTATIC="--disable-static"
    TSHARED="--disable-shared"
    if [ $2 = "static" ]; then
      TSTATIC="--enable-static"
    else
      TSHARED="--enable-shared"
    fi
    
    StartBuild $AD_SDL2_TTF $AD_SDL2_TTF_DIR $1
    
    touch configure.ac aclocal.m4 configure Makefile.am Makefile.in

    if [ $AD_OS = "macos" ]
    then

      $AD_SDL2_TTF_FULL/./configure CFLAGS="$TCFLAGS" $TSHARED $TSTATIC --prefix=$AD_SDL2_TTF_FULL/build/$1 --exec-prefix=$AD_SDL2_TTF_FULL/build/$1 --with-freetype-prefix=$AD_FREETYPE_FULL/build/$1/include/freetype2 --with-freetype-exec-prefix=$AD_FREETYPE_FULL/build/$1/lib --with-sdl-prefix=$AD_SDL2_FULL/build/$1 --with-sdl-exec-prefix=$AD_SDL2_FULL/build/$1 CPPFLAGS="-I$AD_FREETYPE_FULL/build/$1/include/freetype2" CC="$AD_CC" CXX="$AD_CXX"
      CheckStatus "SDL2_image"
      $AD_MAKE LIBS="-lfreetype -lSDL2 -lpng -lbz2 -framework CoreVideo -framework CoreGraphics -framework ImageIO -framework CoreAudio -framework AudioToolbox -framework Foundation -framework CoreFoundation -framework CoreServices -framework OpenGL -framework ForceFeedback -framework IOKit -framework Cocoa -framework Carbon" LDFLAGS="-L$AD_FREETYPE_FULL/build/$1/lib -L$AD_LIBPNG_FULL/build/$1/lib -L$AD_SDL2_FULL/build/$1/lib -L$AD_BZIP_FULL/build/$1/lib" CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
      CheckStatus "SDL2_ttf"

    else

      #FT2_CONFIG=$AD_FREETYPE_FULL/build/$1/lib/pkgconfig/freetype2.pc
      #FT2_CFLAGS="-L$AD_FREETYPE_FULL/build/$1/lib"
      #--with-ft-prefix=$AD_FREETYPE_FULL/build/$1/include/freetype2 --with-ft-exec-prefix=$AD_FREETYPE_FULL/build/$1/lib
      $AD_SDL2_TTF_FULL/./configure CFLAGS="$TCFLAGS" $TSHARED $TSTATIC $TFLAGS --prefix=$AD_SDL2_TTF_FULL/build/$1 --exec-prefix=$AD_SDL2_TTF_FULL/build/$1 --with-sdl-prefix=$AD_SDL2_FULL/build/$1 --with-sdl-exec-prefix=$AD_SDL2_FULL/build/$1 CPPFLAGS="-I$AD_FREETYPE_FULL/build/$1/include/freetype2 -I$AD_SDL2_FULL/build/$1/include/SDL2" LIBS="-L$AD_SDL2_FULL/build/$1/lib -L$AD_FREETYPE_FULL/build/$1/lib -L$AD_BZIP_FULL/build/$1/lib -L$AD_LIBPNG_FULL/build/$1/lib -L$AD_ZLIB_FULL/build/$1 $TLIBS" CC="$AD_CC" CXX="$AD_CXX" AR="$AD_AR" LD="$AD_LD" STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" FT2_CONFIG=$AD_FREETYPE_FULL/build/$1/lib/pkgconfig/freetype2.pc FT2_LIBS="-L$AD_FREETYPE_FULL/build/$1/lib" FT2_CFLAGS="-I$AD_FREETYPE_FULL/build/$1/include/freetype2"
      
      CheckStatus "SDL2_ttf"
      
      if [ "$AD_COMPILER" = "mingw" ]
      then
        $AD_MAKE -j"$AD_THREADS"
        CheckStatus "SDL2_ttf"
        

        #rename windows files to unix in .dep foler
        if cd .deps ; then
          find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
          cd ../
        fi
        

      else
        $AD_MAKE LIBS="-lfreetype -lSDL2 -lpng -lbz2 " LDFLAGS="-L$AD_FREETYPE_FULL/build/$1/lib -L$AD_LIBPNG_FULL/build/$1/lib -L$AD_SDL2_FULL/build/$1/lib -L$AD_BZIP_FULL/build/$1/lib" -j"$AD_THREADS"
        CheckStatus "SDL2_ttf"
      fi
    fi

    $AD_MAKE install
    EndBuild $AD_SDL2_TTF $AD_SDL2_TTF_DIR $1
  fi
}

BuildSdl2Net()
{
  if [ $5 = "free" ]; then
    echo "Building SDL2_net"
    
    TCFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      TCFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    TLIBS=-lSDL2
    TFLAGS=""
    if [ "$AD_COMPILER" = "mingw" ]
    then
      echo Arch "$3"
      if [ "$3" = "x64" ]
      then
        TFLAGS=--host=x86_64-w64-mingw32
      else
        TFLAGS=--host=i686-w64-mingw32
      fi
      
      TLIBS="-lmingw32 $TLIBS -lSDL2main"
    fi
    
    TSTATIC="--disable-static"
    TSHARED="--disable-shared"
    if [ "$2" = "static" ]; then
      TSTATIC="--enable-static"
    else
      TSHARED="--enable-shared"
    fi
    
    T_AR="AR=$AD_AR"
    if [ AD_OS="macos" ]
    then
      T_AR=""
    fi
    
    StartBuild $AD_SDL2_NET $AD_SDL2_NET_DIR $1
    
    
    touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
        
    $AD_SDL2_NET_FULL/./configure CFLAGS="$TCFLAGS" CXXFLAGS="$TCFLAGS" $TSTATIC $TSHARED $TFLAGS --prefix=$AD_SDL2_NET_FULL/build/$1 --exec-prefix=$AD_SDL2_NET_FULL/build/$1 --with-sdl-prefix=$AD_SDL2_FULL/build/$1 --with-sdl-exec-prefix=$AD_SDL2_FULL/build/$1 CC="$AD_CC" CXX="$AD_CXX" LD="$AD_LD" $T_AR STRIP="$AD_STRIP" RC="$AD_RC" DLLTOOL="$AD_DLLTOOL" RANLIB="$AD_RANLIB" WINDRES="$AD_WINDRES"
    
    CheckStatus "SDL2_net"
    $AD_MAKE CC="$AD_CC" CXX="$AD_CXX" -j"$AD_THREADS"
    CheckStatus "SDL2_net"
    
    if [ "$AD_COMPILER" = "mingw" ]
    then
      #rename windows files to unix in .dep foler
      if cd .deps ; then
        find . -type f -a \( -name "*.Plo" -o -name "*.Po" \) -a -exec sed -i -- 's/D:/\/mnt\/d/g' {} +
        cd ../
      fi
    fi
        
    $AD_MAKE install
    EndBuild $AD_SDL2_NET $AD_SDL2_NET_DIR $1
  fi
}


BuildGlew()
{
  if [ $5 = "free" ]; then
    echo "Building Glew"
    
    TCFLAGS=$AD_CFLAGS
    if [ "$4" = "debug" ]; then
      TCFLAGS=$AD_CFLAGS_DEBUG
    fi
    
    StartBuild $AD_GLEW $AD_GLEW_DIR $1
    
    
    if [ "$2" = "static" ]; then
      $AD_CC src/glew.c -Iinclude -DGLEW_NO_GLU -DGLEW_BUILD -DGLEW_STATIC -lGL -c -o glew.o $TCFLAGS
      CheckStatus "Glew"
      $AD_AR rcs libglew.a glew.o
      CheckStatus "Glew"
    else
      echo "TODO: Currently not building shared glew."
    fi
    
    mkdir -p "build/$1/lib"
    cp libglew.a "build/$1/lib/libglew.a"
    
    #need to remove build folder since it later cannot be merged in the endbuild command
    cp -R "$BASEDIR/thirdparty/$AD_GLEW/$AD_GLEW_DIR/build" "$TEMPDIR/tempbuild"
    rm -r "$BASEDIR/thirdparty/$AD_GLEW/$AD_GLEW_DIR/build"
    EndBuild $AD_GLEW $AD_GLEW_DIR $1
    cp -R "$TEMPDIR/tempbuild" "$BASEDIR/thirdparty/$AD_GLEW/$AD_GLEW_DIR/build"
    rm -r "$TEMPDIR/tempbuild"
    
  fi

}

#https://www.freedesktop.org/wiki/Software/HarfBuzz/
#complex package requires ICU flus freetype circular dependency
#$AD_HARFBUZZ/./configure -h --enable-static


#HARFBUZZ_CFLAGS C compiler flags for HARFBUZZ, overriding pkg-config
#HARFBUZZ_LIBS linker flags for HARFBUZZ, overriding pkg-config



#libcurl
#openssl
#ffmpeg


#STATIC=$1
#ARCH=$2
#PROFILE=$3
#LICENSE=$4
BuildAll()
{

  echo Build
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
  
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_GIFLIB" = true ]
  then
    BuildGiflib $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_LIBWEBP" = true ]
  then
    BuildLibwebp $EXEC_DIR $1 $2 $3 $4
  fi
  
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_BZIP" = true ]
  then
    BuildBzip $EXEC_DIR $1 $2 $3 $4
  fi

  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_FREETYPE" = true ]
  then
    BuildFreetype $EXEC_DIR $1 $2 $3 $4
  fi

  #[ "$AD_BUILD_ALL" = true ] ||
  if  [ "$AD_BUILD_LIBBPG" = true ]
  then
    BuildLibbpg $EXEC_DIR $1 $2 $3 $4
  fi
   
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_SDL2" = true ]
  then
    BuildSdl2 $EXEC_DIR $1 $2 $3 $4
  fi
   
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_SDL2_IMAGE" = true ]
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
  
  if [ "$AD_BUILD_ALL" = true ] || [ "$AD_BUILD_GLEW" = true ]
  then
    BuildGlew $EXEC_DIR $1 $2 $3 $4
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
  BuildLicense $1 $2 "debug"
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


