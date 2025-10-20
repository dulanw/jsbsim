@echo off

set JSBSIM_ROOT=%~dp0

set OUT_DIR=%JSBSIM_ROOT%out
set BUILD_DIR=%JSBSIM_ROOT%out\build
set UE_THIRD_PARTY=%JSBSIM_ROOT%out\UnrealEngine\Source\ThirdParty
set UE_INCLUDE_DIR=%UE_THIRD_PARTY%\JSBSim\Include
set UE_LIB_DIR=%UE_THIRD_PARTY%\JSBSim\Lib
set UE_RESOURCES_DIR=%JSBSIM_ROOT%out\UnrealEngine\Resources\JSBSim
set JSBSIM_UE_PLUGIN=%JSBSIM_ROOT%UnrealEngine\Plugins\JSBSimFlightDynamicsModel\Source\ThirdParty

pushd "%JSBSIM_ROOT%"
echo change dir to: %JSBSIM_ROOT%

if exist "%OUT_DIR%" (
    echo.
    echo deleting existing %OUT_DIR% directory...
    rmdir /s /q "%OUT_DIR%"
)

echo.
echo make directory %BUILD_DIR%
mkdir "%BUILD_DIR%"

echo make directory %UE_INCLUDE_DIR%
mkdir "%UE_INCLUDE_DIR%"

echo make directory %UE_LIB_DIR%
mkdir "%UE_LIB_DIR%"

echo make directory %UE_RESOURCES_DIR%
mkdir "%UE_RESOURCES_DIR%\aircraft"
mkdir "%UE_RESOURCES_DIR%\engine"
mkdir "%UE_RESOURCES_DIR%\systems"

echo.
echo run cmake with DBUILD_SHARED_LIBS=ON
cmake -S . -B "%BUILD_DIR%" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
@REM @REM @REM cmake -S . -B out\build -DCMAKE_CXX_FLAGS_RELEASE="-O3 -march=native -mtune=native" -DCMAKE_C_FLAGS_RELEASE="-O3 -march=native -mtune=native" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON


echo.
echo run cmake build
cmake --build "%BUILD_DIR%" --config Release --target libJSBSim -- /m:8

if errorlevel 1 (
    echo.
    echo build failed!
    exit /b 1
)

echo.
echo copy headers to %UE_INCLUDE_DIR%
xcopy /S /Y "%JSBSIM_ROOT%src\*.h" "%UE_INCLUDE_DIR%"
xcopy /S /Y "%JSBSIM_ROOT%src\*.hxx" "%UE_INCLUDE_DIR%"

echo.
echo copy lib to %UE_LIB_DIR%
xcopy /S /Y "%BUILD_DIR%\src\Release" "%UE_LIB_DIR%"

echo.
echo copy aircraft to %UE_RESOURCES_DIR%\aircraft
xcopy /S /Y "%JSBSIM_ROOT%aircraft" "%UE_RESOURCES_DIR%\aircraft"

echo.
echo copy engine to %UE_RESOURCES_DIR%\engine
xcopy /S /Y "%JSBSIM_ROOT%engine" "%UE_RESOURCES_DIR%\engine"

echo.
echo copy systems to %UE_RESOURCES_DIR%\systems
xcopy /S /Y "%JSBSIM_ROOT%systems" "%UE_RESOURCES_DIR%\systems"

echo.
echo copy JSBSim.Build.cs and JSBSim_APL.xml
copy /Y "%JSBSIM_UE_PLUGIN%\JSBSim.Build.cs" "%UE_THIRD_PARTY%\JSBSim.Build.cs"
copy /Y "%JSBSIM_UE_PLUGIN%\JSBSim\JSBSim_APL.xml" "%UE_THIRD_PARTY%\JSBSim\JSBSim_APL.xml"

echo.
echo.
echo IMPORTANT - COPY TO YOUR_PLUGIN.Build.cs

echo // Stage JSBSim data files
echo string JSBSimRedistFolder = Path.Combine(PluginDirectory, @"Resources\JSBSim\*");
echo RuntimeDependencies.Add(JSBSimRedistFolder, StagedFileType.NonUFS);

popd
PAUSE