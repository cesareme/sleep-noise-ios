#include "AtomicBridge.h"

#include <stdatomic.h>

void sn_seqlock_begin_write(uint32_t *sequence, uint32_t odd) {
    atomic_store_explicit((_Atomic uint32_t *)sequence, odd, memory_order_relaxed);
    atomic_thread_fence(memory_order_seq_cst);
}

void sn_seqlock_end_write(uint32_t *sequence, uint32_t even) {
    atomic_thread_fence(memory_order_release);
    atomic_store_explicit((_Atomic uint32_t *)sequence, even, memory_order_relaxed);
}

uint32_t sn_seqlock_read_begin(uint32_t *sequence) {
    return atomic_load_explicit((_Atomic uint32_t *)sequence, memory_order_acquire);
}

uint32_t sn_seqlock_read_end(uint32_t *sequence) {
    atomic_thread_fence(memory_order_acquire);
    return atomic_load_explicit((_Atomic uint32_t *)sequence, memory_order_relaxed);
}
