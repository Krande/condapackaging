# Compiling Code Aster


## Enable Core Dumps 
First, make sure that core dumps are enabled on your system. 
You can check the current limit by running the command ulimit -c. 
If the value is 0, core dumps are disabled. You can enable them by running ulimit -c unlimited

If you're on ubuntu you might have to turn off `Apport` before running the compilation. 
Do this by entering `sudo service apport stop` (after you're done debugging you can turn it back off `sudo service apport start`).

2. Configure Core Pattern: Check the core pattern that tells the system where to store core dump files. This can be found in /proc/sys/kernel/core_pattern. You may need root permissions to modify this file. The pattern might include certain directives that can be replaced by attributes of the dumped process. You can change it to something simple like core to dump the core files in the working directory of the crashed process.

Check System Configuration: On some systems, core dumps may be redirected to system error reporting tools or specific directories. For example, on some Linux systems, core dumps may be redirected to systemd-coredump. You might be able to retrieve the core dump with a command like coredumpctl dump.

Reproduce the Issue: Once you've ensured that core dumps are enabled and know where they're being stored, you may need to reproduce the issue to generate a new core dump.

Inspect the Core Dump: Once you have the core dump file, you can use tools like gdb to inspect it. Open it with gdb -c /path/to/corefile, and you can analyze the state of the program at the time of the crash.

Check the Program's Working Directory: If the core pattern is set to just core or similar, the dump should be in the working directory of the crashed process. This may or may not be where you're running the program from, depending on how it's set up.

Check Permissions: If the program is set up to run as a different user or with restricted permissions, it might not have permission to write core files where you expect. You may need to tweak permissions or configure the core pattern to write somewhere that's writeable.

Compile with Debug Information: If you're compiling the code yourself, make sure you're building with debug information (e.g., the -g flag in gcc). This will make the core dump much more useful, as you'll have information about line numbers, variable values, etc.