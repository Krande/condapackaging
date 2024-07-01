import subprocess

from med.medfile import MEDfileOpen, MED_ACC_CREAT


def test_medfileopen():
    fid = MEDfileOpen("test1.med", MED_ACC_CREAT)
    # Cast fid from int64 to int
    assert fid == 72057594037927936


def test_shell1():
    # run a shell script build.sh in the external terminal
    subprocess.run(["gnome-terminal", "--", "bash", "-c", "bash build.sh"])
