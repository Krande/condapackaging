import pathlib

import os
cwd = pathlib.Path.cwd()

# File path
file_path = cwd / "OCP.cpp"

# Read the file and filter lines
with open(file_path, "r") as file:
    lines = file.readlines()

# Remove lines containing 'register_IVtk'
filtered_lines = [line for line in lines if "register_IVtk" not in line]

# Write back the filtered content
with open(file_path, "w") as file:
    file.writelines(filtered_lines)

# Remove files starting with "IVtk" in the OCP directory
for filename in cwd.glob("IVtk*"):
    if filename.startswith("IVtk"):
        os.remove(filename)

print("Cleanup and updates completed.")
