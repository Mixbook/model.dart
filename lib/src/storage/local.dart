part of model.storage;

class LocalStorage<E> implements SyncStorage<E> {
  html.Storage get storage => html.window.localStorage;
  Function instantiator;

  LocalStorage(E instantiator(Params params)) {
    this.instantiator = instantiator;
  }

  E find(String identifier) {
    var jsonString = storage[identifier];
    if (jsonString != null) {
      return instantiator(json.parse(jsonString));
    } else {
      return null;
    }
  }

  bool save(E object) {
    storage[object.identifier] = json.stringify(object.toParams());
    return true;
  }

  bool delete(E object) {
    return storage.remove(object.identifier) != null;
  }
}
