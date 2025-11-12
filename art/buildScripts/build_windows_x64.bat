@echo off
color 0a
cd ../..
echo BUILDING WINDOWS 64-BIT
haxelib run lime build windows -release
echo.
echo done - Windows 64-bit build completed!
pause
pwd
