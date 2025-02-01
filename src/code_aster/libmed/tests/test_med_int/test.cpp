#include <med.h>
#include <cstdio>

int main() {
    // Print the size of med_int.
    // Note: Casting sizeof(med_int) to int for printing.
    std::printf("%d", static_cast<int>(sizeof(med_int)));
    return 0;
}
