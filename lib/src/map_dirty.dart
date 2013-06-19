library model.map_dirty;

import 'dart:collection';
import 'dart:mirrors';

class MapDirty<K, V> implements Map<K, V> {
  Map<K, V> _original;
  Map<K, V> _current;

  MapDirty(original, current) {
    _original = original;
    _current = current;
  }

  factory MapDirty.from(Map<K, V> other) {
    return new MapDirty(new Map.from(other), new Map.from(other));
  }

  noSuchMethod(Invocation invocation) {
    return reflect(_current).delegate(invocation);
  }

  bool get isChanged => !summaryChanges.isEmpty;

  String toString() => _current.toString();

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
