#ifndef AtomicBridge_h
#define AtomicBridge_h

#include <stdint.h>

/// Seqlock helpers. The main thread is the only writer; the audio render
/// thread is the only reader. Plain release/acquire stores are one-way
/// barriers, so on their own they let the control-block write drift above
/// the odd store (writer) and the control-block read sink below the final
/// sequence load (reader). The fences here close both gaps.

/// Writer: mark the sequence odd, then fence so the payload stores cannot
/// become visible before the odd mark.
void sn_seqlock_begin_write(uint32_t *sequence, uint32_t odd);

/// Writer: fence so every payload store is visible before the even mark.
void sn_seqlock_end_write(uint32_t *sequence, uint32_t even);

/// Reader: first sequence load, acquire.
uint32_t sn_seqlock_read_begin(uint32_t *sequence);

/// Reader: fence so the payload loads complete before the second sequence load.
uint32_t sn_seqlock_read_end(uint32_t *sequence);

#endif
