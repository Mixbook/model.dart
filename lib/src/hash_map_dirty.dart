library model.hash_map_dirty;

import 'dart:collection';

class HashMapDirty<K, V> extends HashMap<K, V> {
  HashMap<K, V> _original;

  HashMapDirty(Map<K, V> other) {
    addAll(other);
    _original = new HashMap.from(this);
  }

  bool get hasChanges => !summaryChanges.isEmpty;

  Map<K, V> get summaryChanges {
    var changes = new Map<K, V>();
    (new Set.from(keys)..addAll(_original.keys))..forEach((k) {
      if (!(containsKey(k) && _original.containsKey(k) && this[k] == _original[k])) {
        changes[k] = this[k];
      }
    });
    return changes;
  }
}
