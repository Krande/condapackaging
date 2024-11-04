missing_packages = [
        ("Le fichier xmgrace n'existe pas",),
        ("ModuleNotFoundError: No module named 'scipy'",),
        ("run_miss3d: not found",),
        ("No module named 'asrun'",),
        ("No module named 'petsc4py'",),
        ("Le fichier homard est inconnu.",),  # 18 tests!
    ]

numpy_failures = [
    (
        "AttributeError: module 'numpy' has no attribute 'float'.",
        'MacroCommands/post_endo_fiss_ops.py", line 831',
    ),
    (
        "AttributeError: module 'numpy' has no attribute 'complex'.",
        'zzzz313a.comm.changed.py", line 44',
    ),
]
unclassified_fail_messages = [
    # Uncategorized
    # mpi-related
    ("<F> <DVP_97>", "Erreur signalée dans la bibliothèque MED", "nom de l'utilitaire : mfiope"),
    ("<F> <DVP_97>", "Erreur signalée dans la bibliothèque MED", "nom de l'utilitaire : mpfprw"),
    (
        "<stdout>:cannot remove",
        "Operation not permitted[1,0]<stdout>",
        "No such file or directory: 'pick.code_aster.objects'",
    ),
    (
        "<stdout>:cannot remove",
        'File : "mesh_1.med" has been detected as NOT EXISTING : impossible to read anything !',
    ),
    ("sysmalloc: Assertion `(old_top == initial_top (av)",),
    ("malloc(): invalid size (unsorted)", "=134", "<F>_ABNORMAL_ABORT"),
    ("malloc(): mismatching next->prev_size (unsorted)",),
    ("PETSC ERROR", "Caught signal number 11 SEGV: Segmentation Violation"),
    ("munmap_chunk(): invalid pointer", "LinearSolver.cxx"),
    ("munmap_chunk(): invalid pointer", "Avancement du calcul"),
    ("<EXCEPTION> <FACTOR_10>", "la matrice est singulière ou presque singulière"),
    ("malloc.c:4302: _int_malloc: Assertion `(unsigned long) (size) >= (unsigned long) (nb)'",),
    ("free(): invalid next size (fast)", "Fatal Python error: Aborted"),
    ("python3: malloc.c:4105: _int_malloc: Assertion `chunk_main_arena (bck->bk)' failed.",),
    ("ImportError: cannot import name 'ImportPETSc' from 'petsc4py.lib' (unknown location)",),
    (
        "<F> <FACTOR_55>",
        "PARMETIS ERROR: Poor initial vertex distribution. Processor 0 has no vertices assigned to it!",
    ),
    # ("PARTITIONNEUR='METIS'", "=139", "<F>_ABNORMAL_ABORT"),
    ("malloc(): unaligned tcache chunk detected",),
    ("corrupted size vs. prev_size", "<F>_ABNORMAL_ABORT", "=134"),
    ("<F> <ALGORITH9_17>", "Le nombre de pas est négatif"),
    ("double free or corruption (!prev)", "<F>_ABNORMAL_ABORT"),
    # non-mpi (likely)
    (
        "<F> <DVP_1>",
        "La commande CALC_ERC_DYN ne peut fonctionner que sur des maillages ne contenant que des SEG2",
    ),
    ("<F> <DVP_1>", "dmax .gt. 0.d0"),
    ("<EXCEPTION> <DVP_1>", "dmax .gt. 0.d0"),
    ("<F> <DVP_1>", "ier .eq. 0"),
    (
        "<F> <HHO1_4>",
        "Échec de la factorisation de Cholesky: la matrice n'est pas symétrique définie positive",
    ),
    ("<F> <DVP_2>", "Erreur numérique (floating point exception)"),
    ("<EXCEPTION> <DVP_2>", "Erreur numérique (floating point exception)"),
    ("Fortran runtime error: Unit number in I/O statement too large", "acearp.F90"),
    ("<F> <UTILITAI6_77>",),
    ("<F> <ELEMENTS2_57>", "La modélisation T3G ne permet pas de bien"),
    ("<F> <FACTOR_11>", "la matrice est singulière ou presque singulière"),
    ("AttributeError: 'libaster.Function' object has no attribute 'getMaterialNames'",),
    ("TypeError: 'float' object cannot be interpreted as an integer",),
    ("<F> <FERMETUR_13>", "libumat.so: cannot open shared object file"),
    ("Fatal Python error: Segmentation fault", "=139"),
    ("JeveuxCollection.h", "ABORT - exit code 17", "seems empty"),
    ("Killed", "137"),
    ("NOOK_TEST_RESU",),
    (
        "<F> <MED_18>",
        "Vous essayer de partitionner le maillage alors que le calcul est séquentiel",
        "Pour enlever cette alarme, utiliser le mot-clé SANS dans PARTITIONNEUR",
    ),
    (
        "<F> <FACTOR_48>",
        "Une option d'accélération non disponible avec cette version de MUMPS a été activée",
        "Pour continuer malgré tout le calcul, on lui a substitué l'option F",
    ),
    ("<F> <FACTOR_90>", "Vous avez paramétré le solveur linéaire MUMPS avec le renuméroteur 'PARMETIS'"),
]

failed_termination_msg = "_ERROR"
abnormal_termination_msg = "_ABNORMAL_ABORT"
not_ok_result = "NOOK_TEST_RESU"
