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

/// One-word cell that travels the other way: the render thread is the only
/// writer during playback and the main thread reads. A relaxed store and a
/// relaxed load of one aligned 32-bit word never block and never tear, and the
/// value stands alone, so it needs no ordering against other memory.
void sn_cell_store(uint32_t *cell, uint32_t value);

/// Reader side of `sn_cell_store`.
uint32_t sn_cell_load(uint32_t *cell);

#endif
