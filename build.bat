

IF "%1"=="mingw" SET PATH=%PATH%;C:\dev\mingw-w64\x86_64-7.1.0-posix-sjlj-rt_v5-rev2\mingw64\bin
  
IF "%1"=="clang" SET PATH=%PATH%;C:\dev\LLVM\bin

::IF "%1"=="msvc" SET PATH=%PATH%;"C:\Program Files (x86)\MSBuild\14.0\Bin\amd64"
IF "%1"=="msvc" "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
  
echo %PATH%