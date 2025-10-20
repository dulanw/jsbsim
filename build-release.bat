@echo off
pushd %~dp0

echo change dir to: %~dp0

if exist "out" (
    echo.
    echo Deleting existing build directory...
    rmdir /s /q "out"
)

echo.
echo make out\build dir
mkdir out\build

echo.
echo run cmake with DBUILD_SHARED_LIBS=ON
cmake -S . -B out\build -DCMAKE_CXX_FLAGS_RELEASE="-O3 -march=native -mtune=native" -DCMAKE_C_FLAGS_RELEASE="-O3 -march=native -mtune=native" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON

popd

PAUSE