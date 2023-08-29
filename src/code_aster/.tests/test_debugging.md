# Test Debugging

## Difference in test results across python versions

For some reason there are a far greater number of failed tests for python 3.9/3.10 compared with python 3.11.

The issues manifests itself as `<F> <DVP_2>` floating point errors. 


```
 ╔════════════════════════════════════════════════════════════════════════════════════════════════╗
 ║ <F> <DVP_2>                                                                                    ║
 ║                                                                                                ║
 ║ Erreur numérique (floating point exception).                                                   ║
 ║                                                                                                ║
 ║                                                                                                ║
 ║ Cette erreur est fatale. Le code s'arrête.                                                     ║
 ║ Il y a probablement une erreur dans la programmation.                                          ║
 ║ Veuillez contacter votre assistance technique.                                                 ║
 ╚════════════════════════════════════════════════════════════════════════════════════════════════╝

Traceback returned by GNU libc (last 25 stack frames):
/home/krande/mambaforge/envs/codeasterpy310/lib/aster/libbibc.so(print_trace_+0x33) [0x7fb68bf75f03]
/home/krande/mambaforge/envs/codeasterpy310/lib/aster/libbibfor.so(trabck_+0x3a) [0x7fb68dd78fa8]
/home/krande/mambaforge/envs/codeasterpy310/lib/aster/libbibfor.so(utmess_core_+0x731) [0x7fb68dc185fc]
/home/krande/mambaforge/envs/codeasterpy310/lib/aster/libbibfor.so(utmess_+0xa5d) [0x7fb68dc17e78]
/home/krande/mambaforge/envs/codeasterpy310/lib/aster/libbibfor.so(utmfpe_+0x45) [0x7fb68dd8ad96]
/home/krande/mambaforge/envs/codeasterpy310/lib/aster/libbibc.so(hanfpe+0x9) [0x7fb68bf751b9]
/lib/x86_64-linux-gnu/libc.so.6(+0x42520) [0x7fb68f083520]
/home/krande/mambaforge/envs/codeasterpy310/lib/python3.10/lib-dynload/cmath.cpython-310-x86_64-linux-gnu.so(+0xb6cc) [0x7fb607fd16cc]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(PyModule_ExecDef+0x70) [0x55ce17e94400]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(+0x1ea8a9) [0x55ce17e958a9]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(+0x143792) [0x55ce17dee792]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyEval_EvalFrameDefault+0x5d28) [0x55ce17de42f8]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyFunction_Vectorcall+0x6f) [0x55ce17def21f]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyEval_EvalFrameDefault+0x4a25) [0x55ce17de2ff5]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyFunction_Vectorcall+0x6f) [0x55ce17def21f]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyEval_EvalFrameDefault+0x6f3) [0x55ce17ddecc3]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyFunction_Vectorcall+0x6f) [0x55ce17def21f]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyEval_EvalFrameDefault+0x304) [0x55ce17dde8d4]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyFunction_Vectorcall+0x6f) [0x55ce17def21f]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyEval_EvalFrameDefault+0x304) [0x55ce17dde8d4]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyFunction_Vectorcall+0x6f) [0x55ce17def21f]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(+0x143965) [0x55ce17dee965]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyObject_CallMethodIdObjArgs+0x13b) [0x55ce17dfedcb]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(PyImport_ImportModuleLevelObject+0xc68) [0x55ce17dfe6b8]
/home/krande/mambaforge/envs/codeasterpy310/bin/python3(_PyEval_EvalFrameDefault+0x3c8d) [0x55ce17de225d]
Fatal Python error: Aborted

Current thread 0x00007fb68f03e740 (most recent call first):
  File "<frozen importlib._bootstrap>", line 241 in _call_with_frames_removed
  File "<frozen importlib._bootstrap_external>", line 1184 in exec_module
  File "<frozen importlib._bootstrap>", line 688 in _load_unlocked
  File "<frozen importlib._bootstrap>", line 1006 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1027 in _find_and_load
  File "/home/krande/mambaforge/envs/codeasterpy310/lib/aster/code_aster/MacroCommands/test_fonction_ops.py", line 22 in <module>
  File "<frozen importlib._bootstrap>", line 241 in _call_with_frames_removed
  File "<frozen importlib._bootstrap_external>", line 883 in exec_module
  File "<frozen importlib._bootstrap>", line 688 in _load_unlocked
  File "<frozen importlib._bootstrap>", line 1006 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1027 in _find_and_load
  File "/home/krande/mambaforge/envs/codeasterpy310/lib/aster/code_aster/Utilities/base_utils.py", line 76 in import_object
  File "/home/krande/mambaforge/envs/codeasterpy310/lib/aster/code_aster/Supervis/ExecuteCommand.py", line 660 in __init__
  File "/home/krande/mambaforge/envs/codeasterpy310/lib/aster/code_aster/Supervis/ExecuteCommand.py", line 179 in run
  File "/tmp/run_aster_xc7k8e4t/./sslv160b.comm.changed.py", line 124 in <module>

Extension modules: aster, aster_core, numpy.core._multiarray_umath, numpy.core._multiarray_tests, numpy.linalg._umath_linalg, numpy.fft._pocketfft_internal, numpy.random._common, numpy.random.bit_generator, numpy.random._bounded_integers, numpy.random._mt19937, numpy.random.mtrand, numpy.random._philox, numpy.random._pcg64, numpy.random._sfc64, numpy.random._generator, aster_fonctions, med_aster, yaml._yaml, med._medenum, med._medequivalence, med._medfamily, med._medfield, med._medfile, med._medfilter, med._medinterp, med._medlibrary, med._medlink, med._medlocalization, med._medmesh, med._medparameter, med._medprofile (total: 31)
Aborted (core dumped)

EXECUTION_CODE_ASTER_EXIT_1263=134


restoring result databases from 'BASE_PREC'...
WARNING: execution failed (command file #1): <F>_ERROR
```

When running gdb and a backtrace on the issue, a missing file error is mentioned 
`cmathmodule.c: No such file or directory`. 

```
# Commande #0021 de /tmp/run_aster_5gekeqby/./sslv160b.comm.changed.py, ligne 122
DN105Z = RECU_FONCTION(GROUP_NO='N105',
                       INFO=1,
                       NOM_CHAM='DEPL',
                       NOM_CMP='DZ',
                       RESULTAT=RefM3D)

# Résultat commande #0021 (RECU_FONCTION): DN105Z ('<0000002b>') de type <Function>
# Mémoire (Mo) :  2567.55 /  2527.54 /   208.23 /   197.97 (VmPeak / VmSize / Optimum / Minimum)
# Fin commande #0021   user+syst:        0.02s (syst:        0.00s, elaps:        0.02s)
# ----------------------------------------------------------------------------------------------

Thread 1 "python3" received signal SIGFPE, Arithmetic exception.
0x00007fff63c846cc in cmath_exec (mod=0x7fff6eae9d50) at /usr/local/src/conda/python-3.10.8/Modules/cmathmodule.c:1293
1293    /usr/local/src/conda/python-3.10.8/Modules/cmathmodule.c: No such file or directory.
```

One hypethesis might be that this is linked with a 
[cmake cross-linux issue](https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots)
when compiling on a newer version of linux than the target system.

Update: It seems cross-linux compilation is not the issue. The same error occurs when compiling on the target system.

However, by adding `import cmath` to the top of the AUTO_IMPORTS list in `aster/code_aster/Utilities/base_utils.py` the issue is resolved.