part of model.storage;

class LocalStorage implements SyncStorage<Model> {
  html.Storage get storage => html.window.localStorage;
  Function instantiator;

  LocalStorage(Model instantiator(Map<String, Object> params)) {
    this.instantiator = instantiator;
  }

  Model find(String identifier) {
    var jsonString = storage[identifier];
    if (jsonString != null) {
      return instantiator(json.parse(jsonString));
    } else {
      return null;
    }
  }

  bool save(Model object) {
    storage[object.id.toString()] = json.stringify(object.toParams());
    return true;
  }

  bool delete(Model object) {
    return storage.remove(object.id.toString()) != null;
  }
}
