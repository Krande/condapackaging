### Changes on include files

The changes allow to build code_aster with `-i8` option and keep short integers
in the Mumps interface using these changed includes.

Declarations are forced to be of size 4 for integers, reals and logicals:

```bash
    sed -i 's/INTEGER *,/INTEGER(4),/g' include/*_{struc,root}.h
    sed -i 's/INTEGER *::/INTEGER(4) ::/g' include/*_{struc,root}.h
    sed -i 's/INTEGER MPI/INTEGER(4) MPI/g' libseq/mpif.h
    sed -i 's/REAL *,/REAL(4),/g' include/*_{struc,root}.h libseq/mpif.h
    sed -i 's/REAL *::/REAL(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
    sed -i 's/COMPLEX *,/COMPLEX(4),/g' include/*_{struc,root}.h libseq/mpif.h
    sed -i 's/COMPLEX *::/COMPLEX(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
    sed -i 's/LOGICAL *,/LOGICAL(4),/g' include/*_{struc,root}.h libseq/mpif.h
    sed -i 's/LOGICAL *::/LOGICAL(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
```

Do not forget to check long lines (< 72 chars).

