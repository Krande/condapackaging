# Debug Information Changes for MUMPS

## Problem
When using MUMPS library compiled with debug symbols in downstream projects, linker warnings were appearing:
```
warning LNK4099: PDB '' was not found with 'dmumps.lib(mumps_c.c.obj)' or at ''; linking object as if no debug info
```

These warnings occurred for all MUMPS libraries (dmumps, zmumps, smumps, cmumps, mumps_common, pord, mpiseq).

## Root Cause
The MUMPS build was using `/Zi` compiler flag which creates separate PDB (Program Database) files for debug information. These PDB files were not being installed with the libraries, causing downstream projects to fail finding them.

## Solution
Changed the debug build to use `/Z7` compiler flag instead of `/Zi`. This embeds debug information directly into the object files (`.obj`) and static libraries (`.lib`), eliminating the need for separate PDB files.

### Changes Made

#### 1. MUMPS build.bat
- Changed CFLAGS from `/Zi` to `/Z7` for debug builds
- Changed FCFLAGS from `/Zi` to `/Z7` for debug builds
- Added `CMAKE_MSVC_DEBUG_INFORMATION_FORMAT=Embedded` to CMake configuration

#### 2. Scotch bld-scotch.bat
- Changed CFLAGS from `/Zi` to `/Z7` for debug builds (MSVC compiler)
- Changed FCFLAGS from `/Zi` to `/Z7` for debug builds (MSVC compiler)
- Added `CMAKE_MSVC_DEBUG_INFORMATION_FORMAT=Embedded` to CMake configuration
- Flang compiler continues to use `-g` flag (unchanged)

## Benefits
1. **No missing PDB warnings**: Debug information is embedded in the libraries
2. **Simpler distribution**: No need to track and distribute separate PDB files
3. **Consistency**: Matches the approach already used in the metis package
4. **Better compatibility**: Works seamlessly with downstream projects

## Note
The metis package was already using this approach (`/Z7`), so this change brings MUMPS and scotch in alignment with the existing best practice in the project.

