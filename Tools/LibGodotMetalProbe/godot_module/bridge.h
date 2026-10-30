#pragma once
#include <stdint.h>
// C ABI only; all native ObjC objects remain owned by the producer until stop.
struct DoraGodotProbeSlot { void *texture; void *ready; void *consumed; };
struct DoraGodotProbeStats {
    uint64_t produced, completed, errors, reuse_waits, buffers;
};
