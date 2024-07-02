import os
import pathlib
import subprocess
import pytest
import sys

from med.medfile import MEDfileOpen, MED_ACC_CREAT


def test_medfileopen():
    fid = MEDfileOpen("test1.med", MED_ACC_CREAT)
    # Cast fid from int64 to int
    assert fid == 72057594037927936


@pytest.mark.skipif(sys.platform == "win32", reason="Not running on Window")
def test_shell_linux1():
    # run a shell script build.sh in the external terminal
    subprocess.run(["gnome-terminal", "--", "bash", "-c", "bash build.sh"], cwd="test1", check=True)


@pytest.mark.skipif(sys.platform != "win32", reason="Only running on Window")
def test_shell_win1():
    # run a shell script build.bat in the external terminal
    subprocess.run(["cmd", "/c", "start", "build.bat"], cwd="test1", check=True)


@pytest.mark.skipif(sys.platform != "win32", reason="Only running on Window")
def test_shell_win2():
    # run a shell script build.bat in the external terminal
    subprocess.run(["cmd", "/c", "start", "build.bat"], cwd="test2", check=True)

def test_direct_access():
    import ctypes

    prefix = pathlib.Path(os.getenv('CONDA_PREFIX'))
    bin_dir = prefix / 'Library' / 'bin'
    dll_file = bin_dir / 'medfwrap.dll'

    # Load the shared library
    lib = ctypes.CDLL(dll_file.as_posix())

    # Define the Fortran subroutine signature
    lib.MFIVOP.argtypes = [ctypes.POINTER(ctypes.c_longlong),
                           ctypes.c_char_p,
                           ctypes.POINTER(ctypes.c_longlong),
                           ctypes.POINTER(ctypes.c_longlong),
                           ctypes.POINTER(ctypes.c_longlong),
                           ctypes.POINTER(ctypes.c_longlong),
                           ctypes.POINTER(ctypes.c_longlong)]

    # Prepare the arguments
    fid = ctypes.c_longlong(0)
    # Ensure the string buffer length matches the Fortran character length (200 characters)
    name = ctypes.create_string_buffer(b'example_string' + b' ' * (200 - len('example_string')))
    access = ctypes.c_longlong(3)
    major = ctypes.c_longlong(3)
    minor = ctypes.c_longlong(3)
    rel = ctypes.c_longlong(1)
    cret = ctypes.c_longlong(0)

    # Call the Fortran subroutine
    print("Before mfivop call:", name.value)
    lib.MFIVOP(ctypes.byref(fid), name, ctypes.byref(access),
               ctypes.byref(major), ctypes.byref(minor),
               ctypes.byref(rel), ctypes.byref(cret))
    print("After mfivop call:", name.value)
