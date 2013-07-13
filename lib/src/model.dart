library model.model;

import 'dart:async';
import 'dart:collection';
import 'package:model/src/params.dart';
import 'package:model/src/request.dart';
import 'package:model/src/storage.dart';
import 'package:model/src/hash_map_dirty.dart';
import 'package:model/src/changeable_uri.dart';

abstract class Model {
  HashMapDirty attributes = new HashMapDirty();
  bool isLoaded = false;
  bool isAutosaveEnabled = false;
  bool get isNewRecord => id == null;
  int get id => getIntValue(attributes["id"]);
  Params errors;

  bool _isLoading = false;
  Future<bool> _loadFuture;
  AsyncStorage storage;
  Timer _autosaveTimer;

  Model(Storage storage, [Params params]) {
    this.storage = storage;
    if (params != null) {
      attributes = new HashMapDirty.from(params);
    }

    if (_isParamsForLoaded(params)) {
      isLoaded = true;
      _loadFuture = new Future<bool>(() => true);
    } else {
      isLoaded = false;
    }
  }

  ChangeableUri get memberUri => storage.request.adjustUri(storage.buildUri("member", id));
  ChangeableUri get collectionUri => storage.request.adjustUri(storage.buildUri("collection"));

  Future<bool> load() {
    if (!isLoaded && !_isLoading) {
      _isLoading = true;
      _loadFuture = storage.find(id).then((params) {
        attributes.addAll(params);
        isLoaded = true;
        _isLoading = false;
        return true;
      });
    }
    return _loadFuture;
  }

  Future<bool> save() {
    return storage.save(this)
        .then((params) {
          attributes = new HashMapDirty.from(params);
          return true;
        })
        .catchError((errors) {
          this.errors = errors;
          return false;
        });
  }

  Future<bool> delete() {
    return storage.delete(this).then((params) {
      return params["errors"] == null || params["errors"].isEmpty;
    });
  }

  void startAutosave(Duration duration) {
    if (!isAutosaveEnabled) {
      isAutosaveEnabled = true;
      _autosave(duration);
    }
  }

  void stopAutosave() {
    isAutosaveEnabled = false;
    if (_autosaveTimer != null) {
      _autosaveTimer.cancel();
      _autosaveTimer = null;
    }
  }

  Params toParams([String type]) {
    if (type == "update") {
      return ({"id": id} as HashMap)..addAll(attributes.summaryChanges);
    } else {
      return new Map.from(attributes);
    }
  }

  int getIntValue(string) {
    return string == null ? null : int.parse(string.toString());
  }

  bool _isParamsForLoaded(Params params) {
    return !(params.length == 1 && params.keys.toList()[0] == "id");
  }

  int get hashCode {
    return id != null ? id.hashCode + runtimeType.hashCode : super.hashCode;
  }

  bool operator == (Model other) {
    if (id != null && other != null) {
      return id == other.id && runtimeType == other.runtimeType;
    } else {
      return super == other;
    }
  }

  void _autosave(Duration duration) {
    if (isAutosaveEnabled) {
      _autosaveTimer = new Timer(duration, () {
        save().then((_) => _autosave(duration));
      });
    }
  }
}
