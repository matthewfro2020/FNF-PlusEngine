@echo off
color 0a
cd ../..
echo BUILDING ANDROID arm64-v8a (64-bit)
haxelib run lime build android -release -D ANDROID_ABI=arm64-v8a
echo.
echo BUILDING ANDROID armeabi-v7a (32-bit)
haxelib run lime build android -release -D ANDROID_ABI=armeabi-v7a
echo.
echo done - Both Android builds completed!
pause
pwd
