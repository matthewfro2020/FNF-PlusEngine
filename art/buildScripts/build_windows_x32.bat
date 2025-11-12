@echo off
color 0a
cd ../..
echo BUILDING WINDOWS 32-BIT
haxelib run lime build windows -32 -release -D 32bits -D HXCPP_M32
echo.
echo done - Windows 32-bit build completed!
pause
pwd
