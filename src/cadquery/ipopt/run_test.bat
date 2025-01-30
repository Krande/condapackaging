setlocal EnableDelayedExpansion

:: Check .pc file
pkg-config --exists --print-errors --debug ipopt
if errorlevel 1 exit 1

pkg-config --validate --print-errors --debug ipopt
if errorlevel 1 exit 1

:: Make sure that Windows native find is found before the find in C:\Miniconda\Library\usr\bin\
set PATH=C:\Windows\System32;%PATH%

:: Test the ipopt binary
ipopt mytoy.nl | find "Optimal Solution"

:: Test linking against the ipopt library
cd test

:: Compile example that links ipopt
cl.exe /EHsc /I%PREFIX%\Library\include\coin-or ipopt.lib cpp_example.cpp MyNLP.cpp
if errorlevel 1 exit 1

@REM :: Run example
@REM .\cpp_example.exe mumps | find "Optimal Solution"
@REM if errorlevel 1 exit 1
@REM
@REM :: Compile examples that links the backward-compatibilty import library ipopt-3.lib
@REM :: See https://github.com/conda-forge/ipopt-feedstock/pull/125#issuecomment-2544745043
@REM del .\cpp_example.exe
@REM cl.exe /EHsc /I%PREFIX%\Library\include\coin-or ipopt-3.lib cpp_example.cpp MyNLP.cpp
@REM
@REM if errorlevel 1 exit 1
@REM .\cpp_example.exe mumps | find "Optimal Solution"
@REM if errorlevel 1 exit 1
