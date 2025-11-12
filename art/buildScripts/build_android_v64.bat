@echo off
color 0a
cd ../..
echo BUILDING ANDROID arm64-v8a (v64)
haxelib run lime build android -release -D ANDROID_ABI=arm64-v8a
echo.
echo done - Android v64 build completed!
pause
pwd
