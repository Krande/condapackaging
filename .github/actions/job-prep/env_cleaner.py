import os

# List of essential directories to keep
KEEP_PATHS = [
    r"C:\Program Files (x86)\Intel\oneAPI\compiler",  # Intel OneAPI
    r"C:\Program Files\Microsoft Visual Studio",  # MSVC
    r"C:\Windows\system32",  # Essential system utilities
    r"C:\Windows",  # Essential system utilities
    r"C:\Windows\System32\Wbem",  # Windows Management
    r"C:\Windows\System32\WindowsPowerShell\v1.0",  # PowerShell
    r"C:\Program Files\Git\bin",  # Git
]

# Fetch the current PATH variable
original_path = os.environ.get("PATH", "")
path_dirs = original_path.split(";")

# Remove duplicate entries
path_dirs = list(dict.fromkeys(path_dirs))

# Filter paths to keep only essential ones
cleaned_path = [p for p in path_dirs if any(keep in p for keep in KEEP_PATHS)]

# Join the cleaned path list back
cleaned_path_str = ";".join(cleaned_path)

# Print the cleaned path
print("Original PATH length:", len(original_path))
print("Cleaned PATH length:", len(cleaned_path_str))
print("\nCleaned PATH:")
print(cleaned_path_str)

# (Optional) Set the cleaned PATH in the current session
os.environ["PATH"] = cleaned_path_str
