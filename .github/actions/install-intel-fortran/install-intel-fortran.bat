:: Download installer
curl.exe --url https://registrationcenter-download.intel.com/akdlm/IRC_NAS/2bff9d18-ac2b-40b1-8167-00156f466b0e/intel-fortran-essentials-2025.0.0.301_offline.exe --output intel-fortran-essentials-2025.0.0.301_offline.exe

:: Run the installer in silent mode
intel-fortran-essentials-2025.0.0.301_offline.exe -s -a --silent --eula accept -p=NEED_VS2019_INTEGRATION=0 -p=NEED_VS2022_INTEGRATION=0

:: Clean up
del intel-fortran-essentials-2025.0.0.301_offline.exe