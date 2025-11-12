@echo off
color 0a
cd ../..
echo BUILDING ANDROID armeabi-v7a (v7a)
haxelib run lime build android -release -D ANDROID_ABI=armeabi-v7a
echo.
echo done - Android v7a build completed!
pause
pwd
