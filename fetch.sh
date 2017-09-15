#!/bin/sh

#zlib
#https://zlib.net/
#SHA-256 hash 4ff941449631ace0d4d203e3483be9dbc9da454084111f97ea0a2114e19bf066
wget -P ../thirdparty/zlib/ https://zlib.net/zlib-1.2.11.tar.xz 
tar xf ../thirdparty/zlib/zlib-1.2.11.tar.xz  ../thirdparty/zlib/1.2.11/

#libpng
#http://www.libpng.org/pub/png/libpng.html
#md5 e01be057a9369183c959b793a685ad15
wget -P ../thirdparty/libpng/ ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.32.tar.xz
tar xf ../thirdparty/libpng/libpng-1.6.32.xz  ../thirdparty/1.6.32

#http://www.ijg.org/
wget -P ../thirdparty/libjpeg/ http://www.ijg.org/files/jpegsrc.v9b.tar.gz
tar xf ../thirdparty/zlib/zlib-1.2.11.tar.xz  ../thirdparty/zlib/1.2.11/

#xz
#https://tukaani.org/xz/
wget -P ../thirdparty/xz https://tukaani.org/xz/xz-5.2.3.tar.xz

#libtiff
#http://www.simplesystems.org/libtiff/
wget -P ../thirdparty/libtiff ftp://download.osgeo.org/libtiff/tiff-4.0.8.tar.gz

#http://giflib.sourceforge.net/

#http://www.bzip.org/

#SDL2

#https://freetype.org/index.html

#webp

#SDL2_image

#SDL2_ttf

#SDL2_net
