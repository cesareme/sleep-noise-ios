#include "AtomicBridge.h"

#include <stdatomic.h>

void sn_store_u32_release(uint32_t *storage, uint32_t value) {
    atomic_store_explicit((_Atomic uint32_t *)storage, value, memory_order_release);
}

uint32_t sn_load_u32_acquire(uint32_t *storage) {
    return atomic_load_explicit((_Atomic uint32_t *)storage, memory_order_acquire);
}
