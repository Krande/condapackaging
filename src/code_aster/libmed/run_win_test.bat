@echo off

echo "Running Windows build test"

call tests/test_windows_build.bat

if errorlevel 1 exit 1

python tests/win_build_verification.py --int-type=%INT_TYPE%

if errorlevel 1 exit 1

echo "Windows build test passed"