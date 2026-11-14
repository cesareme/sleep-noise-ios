#ifndef AtomicBridge_h
#define AtomicBridge_h

#include <stdint.h>

/// Release-store a 32-bit value. The render thread pairs this with
/// `sn_load_u32_acquire` so a control block written between the two stores
/// of a seqlock is visible without taking a lock.
void sn_store_u32_release(uint32_t *storage, uint32_t value);

/// Acquire-load a 32-bit value.
uint32_t sn_load_u32_acquire(uint32_t *storage);

#endif
