

IF "%1"=="mingw" SET PATH=%PATH%;D:\apps\mingw\x86_64-7.2.0-posix-sjlj-rt_v5-rev1\mingw64\bin
  
IF "%1"=="clang" SET PATH=%PATH%;C:\dev\LLVM\bin

::IF "%1"=="msvc" SET PATH=%PATH%;"C:\Program Files (x86)\MSBuild\14.0\Bin\amd64"
IF "%1"=="msvc15" "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
:: "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
:: "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x86
  
echo %PATH%