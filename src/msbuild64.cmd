@echo off
setlocal enabledelayedexpansion

for /f "usebackq tokens=*" %%i in (`vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  "%InstallDir%\MSBuild\15.0\Bin\MSBuild.exe" %*
)