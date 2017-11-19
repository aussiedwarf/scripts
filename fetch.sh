#!/bin/sh

mkdir thirdparty

#zlib
#https://zlib.net/
#SHA-256 hash 4ff941449631ace0d4d203e3483be9dbc9da454084111f97ea0a2114e19bf066
mkdir thirdparty/zlib/

if [ ! -f thirdparty/zlib/zlib-1.2.11.tar.xz ]; then
  wget -O thirdparty/zlib/zlib-1.2.11.tar.xz https://zlib.net/zlib-1.2.11.tar.xz 
  tar -xf thirdparty/zlib/zlib-1.2.11.tar.xz -C thirdparty/zlib/
fi

#libpng
#http://www.libpng.org/pub/png/libpng.html
#md5 e01be057a9369183c959b793a685ad15
mkdir thirdparty/libpng
if [ ! -f thirdparty/libpng/libpng-1.6.32.tar.xz ]; then
  wget -O thirdparty/libpng/libpng-1.6.32.tar.xz https://download.sourceforge.net/libpng/libpng-1.6.32.tar.xz
  tar -xf thirdparty/libpng/libpng-1.6.32.tar.xz -C thirdparty/libpng/
fi

#http://www.ijg.org/
mkdir thirdparty/libjpeg/
if [ ! -f thirdparty/libjpeg/jpegsrc.v9b.tar.gz ]; then
  wget -O thirdparty/libjpeg/jpegsrc.v9b.tar.gz http://www.ijg.org/files/jpegsrc.v9b.tar.gz
  tar -xf thirdparty/libjpeg/jpegsrc.v9b.tar.gz -C thirdparty/libjpeg/
fi

#https://libjpeg-turbo.org/
mkdir thirdparty/libjpeg-turbo
if [ ! -f thirdparty/libjpeg-turbo/libjpeg-turbo-1.5.2.tar.gz ]; then
  wget -O thirdparty/libjpeg-turbo/libjpeg-turbo-1.5.2.tar.gz https://downloads.sourceforge.net/project/libjpeg-turbo/1.5.2/libjpeg-turbo-1.5.2.tar.gz
  tar -xf thirdparty/libjpeg-turbo/libjpeg-turbo-1.5.2.tar.gz -C thirdparty/libjpeg-turbo/
fi

#xz
#https://tukaani.org/xz/
mkdir thirdparty/xz
if [ ! -f thirdparty/xz/xz-5.2.3.tar.xz ]; then
  wget -O thirdparty/xz/xz-5.2.3.tar.xz https://tukaani.org/xz/xz-5.2.3.tar.xz
  tar -xf thirdparty/xz/xz-5.2.3.tar.xz -C thirdparty/xz/
fi

#libtiff
#http://www.simplesystems.org/libtiff/
mkdir thirdparty/libtiff
if [ ! -f thirdparty/libtiff/tiff-4.0.8.tar.gz ]; then
  wget -O thirdparty/libtiff/tiff-4.0.8.tar.gz ftp://download.osgeo.org/libtiff/tiff-4.0.8.tar.gz
  tar -xf thirdparty/libtiff/tiff-4.0.8.tar.gz -C thirdparty/libtiff/
fi


#http://giflib.sourceforge.net/
mkdir thirdparty/giflib
if [ ! -f thirdparty/giflib/giflib-5.1.4.tar.bz2 ]; then
  wget -O thirdparty/giflib/giflib-5.1.4.tar.bz2 https://downloads.sourceforge.net/project/giflib/giflib-5.1.4.tar.bz2
  tar -xf thirdparty/giflib/giflib-5.1.4.tar.bz2 -C thirdparty/giflib/
fi

#http://www.bzip.org/
#md5: 00b516f4704d4a7cb50a1d97e6e8e15b
mkdir thirdparty/bzip2
if [ ! -f thirdparty/bzip2/bzip2-1.0.6.tar.gz ]; then
  wget -O thirdparty/bzip2/bzip2-1.0.6.tar.gz http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
  tar -xf thirdparty/bzip2/bzip2-1.0.6.tar.gz -C thirdparty/bzip2/
fi

#https://freetype.org/index.html
#https://download.savannah.gnu.org/releases/freetype/
mkdir thirdparty/freetype
if [ ! -f thirdparty/freetype/freetype-2.8.1.tar.bz2 ]; then
  wget -O thirdparty/freetype/freetype-2.8.1.tar.bz2 https://download.savannah.gnu.org/releases/freetype/freetype-2.8.1.tar.bz2
  tar -xf thirdparty/freetype/freetype-2.8.1.tar.bz2 -C thirdparty/freetype
fi

#webp
git clone https://chromium.googlesource.com/webm/libwebp thirdparty/webp/master

#SDL1

#SDL2
mkdir thirdparty/SDL

if [ ! -f thirdparty/SDL/SDL2-2.0.7.tar.gz ]; then
  wget -O thirdparty/SDL/SDL2-2.0.7.tar.gz https://www.libsdl.org/release/SDL2-2.0.6.tar.gz
  tar -xf thirdparty/SDL/SDL2-2.0.7.tar.gz -C thirdparty/SDL/
fi

if [ ! -f thirdparty/SDL/SDL2_image-2.0.1.tar.gz  ]; then
  wget -O thirdparty/SDL/SDL2_image-2.0.1.tar.gz https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.1.tar.gz
  tar -xf thirdparty/SDL/SDL2_image-2.0.1.tar.gz -C thirdparty/SDL/
fi

if [ ! -f thirdparty/SDL/SDL2_ttf-2.0.14.tar.gz ]; then
  wget -O thirdparty/SDL/SDL2_ttf-2.0.14.tar.gz https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.14.tar.gz
  tar -xf thirdparty/SDL/SDL2_ttf-2.0.14.tar.gz -C thirdparty/SDL/
fi

if [ ! -f thirdparty/SDL/SDL2_net-2.0.1.tar.gz ]; then
  wget -O thirdparty/SDL/SDL2_net-2.0.1.tar.gz https://www.libsdl.org/projects/SDL_net/release/SDL2_net-2.0.1.tar.gz
  tar -xf thirdparty/SDL/SDL2_net-2.0.1.tar.gz -C thirdparty/SDL/
fi

#libbpg
#https://bellard.org/bpg/
mkdir thirdparty/libbpg
if [ ! -f thirdparty/libbpg/libbpg-0.9.7.tar.gz ]; then
  wget -O thirdparty/libbpg/libbpg-0.9.7.tar.gz https://bellard.org/bpg/libbpg-0.9.7.tar.gz
  tar -xf thirdparty/libbpg/libbpg-0.9.7.tar.gz -C thirdparty/libbpg/
fi

