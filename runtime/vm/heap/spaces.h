// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef RUNTIME_VM_HEAP_SPACES_H_
#define RUNTIME_VM_HEAP_SPACES_H_

#include "platform/atomic.h"
#include "platform/globals.h"

// This file contains utilities shared by old and new space.
// TODO(koda): Create Space base class with Space::CurrentUsage().

namespace dart {

// Usage statistics for a space/generation at a particular moment in time.
class SpaceUsage {
 public:
  SpaceUsage() : capacity_in_words(0), used_in_words(0), external_in_words(0) {}
  RelaxedAtomic<intptr_t> capacity_in_words;
  RelaxedAtomic<intptr_t> used_in_words;
  RelaxedAtomic<intptr_t> external_in_words;

  intptr_t CombinedCapacityInWords() const {
    return capacity_in_words + external_in_words;
  }
  intptr_t CombinedUsedInWords() const {
    return used_in_words + external_in_words;
  }
};

enum class GCType {
  kScavenge,
  kMarkSweep,
  kMarkCompact,
};

enum class GCReason {
  kNewSpace,     // New space is full.
  kStoreBuffer,  // Store buffer is too big.
  kPromotion,    // Old space limit crossed after a scavenge.
  kOldSpace,     // Old space limit crossed.
  kFinalize,     // Concurrent marking finished.
  kFull,         // Heap::CollectAllGarbage
  kExternal,     // Dart_NewFinalizableHandle Dart_NewWeakPersistentHandle
  kIdle,         // Dart_NotifyIdle
  kLowMemory,    // Dart_NotifyLowMemory
  kDebugging,    // service request, etc.
  kSendAndExit,  // SendPort.sendAndExit
};

}  // namespace dart

#endif  // RUNTIME_VM_HEAP_SPACES_H_
