#!/bin/bash
set -x #echo on

mkdir -p thirdparty

#zlib
#https://zlib.net/
#SHA-256 hash 4ff941449631ace0d4d203e3483be9dbc9da454084111f97ea0a2114e19bf066
mkdir -p thirdparty/zlib/

if [ ! -f thirdparty/zlib/zlib-1.2.11.tar.xz ]; then
  wget -O thirdparty/zlib/zlib-1.2.11.tar.xz https://zlib.net/zlib-1.2.11.tar.xz 
  tar -xf thirdparty/zlib/zlib-1.2.11.tar.xz -C thirdparty/zlib/
fi

#libpng
#http://www.libpng.org/pub/png/libpng.html
#md5 e01be057a9369183c959b793a685ad15
mkdir -p thirdparty/libpng
if [ ! -f thirdparty/libpng/libpng-1.6.37.tar.xz ]; then
  wget -O thirdparty/libpng/libpng-1.6.37.tar.xz https://download.sourceforge.net/libpng/libpng-1.6.37.tar.xz
  tar -xf thirdparty/libpng/libpng-1.6.37.tar.xz -C thirdparty/libpng/
fi

#http://www.ijg.org/
mkdir -p thirdparty/libjpeg/
if [ ! -f thirdparty/libjpeg/jpegsrc.v9d.tar.gz ]; then
  wget -O thirdparty/libjpeg/jpegsrc.v9d.tar.gz http://www.ijg.org/files/jpegsrc.v9d.tar.gz
  tar -xf thirdparty/libjpeg/jpegsrc.v9d.tar.gz -C thirdparty/libjpeg/
fi

#https://libjpeg-turbo.org/
mkdir -p thirdparty/libjpeg-turbo
if [ ! -f thirdparty/libjpeg-turbo/libjpeg-turbo-2.0.4.tar.gz ]; then
  wget -O thirdparty/libjpeg-turbo/libjpeg-turbo-2.0.4.tar.gz https://downloads.sourceforge.net/project/libjpeg-turbo/2.0.4/libjpeg-turbo-2.0.4.tar.gz
  tar -xf thirdparty/libjpeg-turbo/libjpeg-turbo-2.0.4.tar.gz -C thirdparty/libjpeg-turbo/
fi

#xz
#https://tukaani.org/xz/
mkdir -p thirdparty/xz
if [ ! -f thirdparty/xz/xz-5.2.4.tar.xz ]; then
  wget -O thirdparty/xz/xz-5.2.4.tar.xz https://tukaani.org/xz/xz-5.2.4.tar.xz
  tar -xf thirdparty/xz/xz-5.2.4.tar.xz -C thirdparty/xz/
fi

#libtiff
#http://www.simplesystems.org/libtiff/
mkdir -p thirdparty/libtiff
if [ ! -f thirdparty/libtiff/tiff-4.1.0.tar.gz ]; then
  wget -O thirdparty/libtiff/tiff-4.1.0.tar.gz https://download.osgeo.org/libtiff/tiff-4.1.0.tar.gz
  tar -xf thirdparty/libtiff/tiff-4.1.0.tar.gz -C thirdparty/libtiff/
fi


#http://giflib.sourceforge.net/
mkdir -p thirdparty/giflib
if [ ! -f thirdparty/giflib/giflib-5.2.1.tar.gz ]; then
  wget -O thirdparty/giflib/giflib-5.2.1.tar.gz https://downloads.sourceforge.net/project/giflib/giflib-5.2.1.tar.gz
  tar -xf thirdparty/giflib/giflib-5.2.1.tar.gz -C thirdparty/giflib/
fi

#http://www.bzip.org/
#md5: 00b516f4704d4a7cb50a1d97e6e8e15b
mkdir -p thirdparty/bzip2
if [ ! -f thirdparty/bzip2/bzip2-1.0.6.tar.gz ]; then
  wget -O thirdparty/bzip2/bzip2-1.0.6.tar.gz https://web.archive.org/web/20180624184806/http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
  tar -xf thirdparty/bzip2/bzip2-1.0.6.tar.gz -C thirdparty/bzip2/
fi

#https://freetype.org/index.html
#https://download.savannah.gnu.org/releases/freetype/
mkdir -p thirdparty/freetype
if [ ! -f thirdparty/freetype/freetype-2.10.1.tar.gz ]; then
  wget -O thirdparty/freetype/freetype-2.10.1.tar.gz https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz
  tar -xf thirdparty/freetype/freetype-2.10.1.tar.gz -C thirdparty/freetype
fi

#webp
mkdir -p thirdparty/libwebp
git clone https://chromium.googlesource.com/webm/libwebp thirdparty/libwebp/libwebp-1.1.0
cd thirdparty/libwebp/libwebp-1.1.0
git branch -v -a
git checkout -b 1.1.0 origin/1.1.0
cd ../../../
#SDL1

#SDL2
mkdir -p thirdparty/SDL

if [ ! -f thirdparty/SDL/SDL2-2.0.10.tar.gz ]; then
  wget -O thirdparty/SDL/SDL2-2.0.10.tar.gz https://www.libsdl.org/release/SDL2-2.0.10.tar.gz
  tar -xf thirdparty/SDL/SDL2-2.0.10.tar.gz -C thirdparty/SDL/
fi

if [ ! -f thirdparty/SDL/SDL2_image-2.0.5.tar.gz  ]; then
  wget -O thirdparty/SDL/SDL2_image-2.0.5.tar.gz https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.5.tar.gz
  tar -xf thirdparty/SDL/SDL2_image-2.0.5.tar.gz -C thirdparty/SDL/
fi

if [ ! -f thirdparty/SDL/SDL2_ttf-2.0.15.tar.gz ]; then
  wget -O thirdparty/SDL/SDL2_ttf-2.0.15.tar.gz https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.15.tar.gz
  tar -xf thirdparty/SDL/SDL2_ttf-2.0.15.tar.gz -C thirdparty/SDL/
fi

if [ ! -f thirdparty/SDL/SDL2_net-2.0.1.tar.gz ]; then
  wget -O thirdparty/SDL/SDL2_net-2.0.1.tar.gz https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz
  tar -xf thirdparty/SDL/SDL2_net-2.0.1.tar.gz -C thirdparty/SDL/
fi

if [ ! -f thirdparty/SDL/SDL2_mixer-2.0.4.tar.gz ]; then
  wget -O thirdparty/SDL/SDL2_mixer-2.0.4.tar.gz https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.4.tar.gz
  tar -xf thirdparty/SDL/SDL2_mixer-2.0.4.tar.gz -C thirdparty/SDL/
fi

#libbpg
#https://bellard.org/bpg/
mkdir -p thirdparty/libbpg
if [ ! -f thirdparty/libbpg/libbpg-0.9.8.tar.gz ]; then
  wget -O thirdparty/libbpg/libbpg-0.9.8.tar.gz https://bellard.org/bpg/libbpg-0.9.8.tar.gz
  tar -xf thirdparty/libbpg/libbpg-0.9.8.tar.gz -C thirdparty/libbpg/
fi

#glew
#http://glew.sourceforge.net/
mkdir -p thirdparty/glew
if [ ! -f thirdparty/glew/glew-2.1.0.tgz ]; then
  wget -O thirdparty/glew/glew-2.1.0.tgz https://sourceforge.net/projects/glew/files/glew/2.1.0/glew-2.1.0.tgz/download
  tar -xf thirdparty/glew/glew-2.1.0.tgz -C thirdparty/glew/
fi


