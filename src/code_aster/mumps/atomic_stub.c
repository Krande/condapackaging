// Stub implementations for GNU atomic builtins
// These are needed when Intel Fortran compiler generates calls to __atomic_* functions
// but we're linking with MSVC linker which doesn't have these symbols

#include <windows.h>
#include <stdint.h>
#include <stdbool.h>

// __atomic_compare_exchange(ptr, expected, desired, weak, success_memorder, failure_memorder)
// Returns true if *ptr was equal to *expected and the swap was performed
bool __atomic_compare_exchange(void* ptr, void* expected, const void* desired,
                               bool weak, int success_memorder, int failure_memorder) {
    // For 32-bit integer (most common case)
    int32_t* p = (int32_t*)ptr;
    int32_t* exp = (int32_t*)expected;
    int32_t des = *(int32_t*)desired;

    int32_t old_val = InterlockedCompareExchange((volatile LONG*)p, des, *exp);

    if (old_val == *exp) {
        return true;
    } else {
        *exp = old_val;
        return false;
    }
}

// __atomic_load(ptr, memorder)
// Returns the value at *ptr
int64_t __atomic_load_8(const void* ptr, int memorder) {
    volatile int64_t* p = (volatile int64_t*)ptr;
#ifdef _WIN64
    return (int64_t)InterlockedCompareExchange64((volatile LONG64*)p, 0, 0);
#else
    // On 32-bit Windows, we need to use a critical section or similar
    // For simplicity, just do a regular load (not truly atomic on 32-bit)
    return *p;
#endif
}

int32_t __atomic_load_4(const void* ptr, int memorder) {
    volatile int32_t* p = (volatile int32_t*)ptr;
    return (int32_t)InterlockedCompareExchange((volatile LONG*)p, 0, 0);
}

// Generic __atomic_load that dispatches based on size
void __atomic_load(int size, const void* ptr, void* ret, int memorder) {
    if (size == 4) {
        *(int32_t*)ret = __atomic_load_4(ptr, memorder);
    } else if (size == 8) {
        *(int64_t*)ret = __atomic_load_8(ptr, memorder);
    }
}

// __atomic_store(ptr, val, memorder)
void __atomic_store_8(void* ptr, int64_t val, int memorder) {
    volatile int64_t* p = (volatile int64_t*)ptr;
#ifdef _WIN64
    InterlockedExchange64((volatile LONG64*)p, val);
#else
    // On 32-bit, not truly atomic for 64-bit values
    *p = val;
#endif
}

void __atomic_store_4(void* ptr, int32_t val, int memorder) {
    volatile int32_t* p = (volatile int32_t*)ptr;
    InterlockedExchange((volatile LONG*)p, val);
}

// Generic __atomic_store that dispatches based on size
void __atomic_store(int size, void* ptr, const void* val, int memorder) {
    if (size == 4) {
        __atomic_store_4(ptr, *(int32_t*)val, memorder);
    } else if (size == 8) {
        __atomic_store_8(ptr, *(int64_t*)val, memorder);
    }
}

