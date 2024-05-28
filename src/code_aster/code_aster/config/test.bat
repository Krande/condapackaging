@echo off

set INCLUDE=
set LIB=
call "C:/Program Files (x86)/Intel/oneAPI/compiler/latest/env/vars.bat" intel64
echo PATH=%%PATH%%
echo INCLUDE=%%INCLUDE%%
echo LIB=%%LIB%%;%%LIBPATH%%