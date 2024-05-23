// test source: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=612621
#include <iostream>
#include <cstdlib>

#include <mpi.h>
#include <ptscotch.h>

int main() {
  int provided;
  SCOTCH_Dgraph dgrafdat;

  MPI_Init_thread(0, 0, MPI_THREAD_MULTIPLE, &provided);

  if (SCOTCH_dgraphInit(&dgrafdat, MPI_COMM_WORLD) != 0) {
    if (MPI_THREAD_MULTIPLE > provided) {
      std::cout << "MPI implementation is not thread-safe:" << std::endl;
      std::cout << "SCOTCH should be compiled without SCOTCH_PTHREAD"
<< std::endl;
      exit(1);
    }
  }
  else {
    SCOTCH_dgraphExit(&dgrafdat);
  }

  MPI_Finalize();

  return 0;
}
