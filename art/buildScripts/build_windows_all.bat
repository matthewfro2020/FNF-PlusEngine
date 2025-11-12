@echo off
color 0a
cd ../..
echo BUILDING WINDOWS 32-BIT and 64-BIT
echo.
echo BUILDING WINDOWS 64-BIT
haxelib run lime build windows -release
echo.
echo BUILDING WINDOWS 32-BIT
haxelib run lime build windows -32 -release -D 32bits -D HXCPP_M32
echo.
echo done - Both Windows builds completed!
pause
pwd
