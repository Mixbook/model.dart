library model.model;

import 'dart:async';
import 'package:model/src/params.dart';
import 'package:model/src/map_dirty.dart';
import 'package:model/src/storage.dart';

abstract class ModelFactory<M> {
  Storage storage;

  Future<M> find(id) {
    return storage.find(id);
  }

  Future<List<M>> collection([Params params]) {
    return storage.collection(params);
  }

  bool matches(Type modelType);
}

abstract class Model {
  MapDirty attributes;
  Storage storage;
  bool isInstantiated = false;
  bool isAutosaveEnabled = false;
  bool get isNewRecord => id == null;
  int get id => attributes["id"] == null ? null : int.parse(attributes["id"].toString());
  Timer autosaveTimer;

  Model(Storage storage, [Params params]) {
    this.storage = storage;
    if (params != null) {
      attributes = new MapDirty.from(params);
    }
  }

  Future<bool> save() {
    return storage.save(this).then((params) {
      attributes = new MapDirty.from(params);
      return params["errors"] != null || params["errors"].isEmpty;
    });
  }

  Future<bool> delete() {
    return storage.delete(this).then((params) {
      return params["errors"] != null || params["errors"].isEmpty;
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
    if (autosaveTimer != null) {
      autosaveTimer.cancel();
      autosaveTimer = null;
    }
  }

  Params toParams([String type]) {
    if (type == "update") {
      return {"id": attributes["id"]}..addAll(attributes.summaryChanges);
    } else {
      return new Map.from(attributes);
    }
  }

  void _autosave(Duration duration) {
    if (isAutosaveEnabled) {
      autosaveTimer = new Timer(duration, () {
        save().then(() => _autosave(duration));
      });
    }
  }
}
