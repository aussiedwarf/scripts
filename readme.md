Scripts
==================

Build scripts
------------------

fetch.sh downloads and instals dependicies

build.sh Build files to build SDL and dependicies for multiple systems

OS's, arch, compilers
Windows VS2015/VS2017/MingW/Clang TODO
  10 x86/x64 TODO
  8.1 x86/x64 TODO
  7 x86/x64 TODO
MacOS Clang 
  Sierra x64
  El Capitan x64
  Yosmite x64
Linux GCC/Clang TODO
  Ubuntu/Mint x86/x64 TODO
  Fedora x86/x64 TODO
  Raspbian arm TODO
  ?Debian,CentOS,OpenSuse,Arch?
iOS arm64 TODO
Android arm/arm64 TODO
Emscripten TODO

Files and Dependencies


zlib
libpng
libjpeg
lzma
libtiff zlib libjpeg lzma
libgif
bzip
freetype zlib bzip libpng 
SDL2
webp libjpeg libtiff libgif libpng sdl1
SDL2_image SDL2 libpng libwebp libtiff libgif libjpeg libpng
SDL2_ttf freetype 
SDL2_net
SDL2_image libpng, libz, libtiff, libjpeg, webp
glew2.0


On Ubuntu the folliwing commands are needed

#Needed to view shared folders in virtualbox
#sudo usermod -a -G vboxsf hypergiant
#copy thirdparty library to dev folder

sudo apt-get install git g++ build-essential libgl1-mesa-glx libgl1-mesa-dev mesa-common-dev libglu1-mesa libglu1-mesa-dev -y

git clone https://github.com/aussiedwarf/scripts.git scripts
cd scripts
./build.sh -c gcc -o ubuntu16.04 -a x64



