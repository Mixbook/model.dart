part of model.storage;

// TODO: Still need to add:
//  * Error handling
//  * Repeating requests if server doesn't respond
//  * Fallback to local storage
//  * #findAll() needs to return some collection class, which is aware of
//    pagination
//  * add class-level (factory-level?) caching of retrieved objects

class RestfulStorage implements AsyncStorage<Model> {
  Request request;
  String resourceName;
  String resourceCollectionName;

  RestfulStorage(this.request, this.resourceName, this.resourceCollectionName);

  Future<Params> find(int id, [Params params]) {
    var future = request.get(buildUri("member", id), params);
    return future.then((response) => response["data"]);
  }

  Future<List<Params>> findAll([Params params]) {
    var future = request.get(buildUri("collection"), params);
    return future.then((response) => response["data"]);
  }

  Future<Params> save(Model object) {
    var future;
    if (object.isNewRecord) {
      future = request.post(buildUri("collection"), _prepareParams(object));
    } else {
      future = request.put(buildUri("member", object.id), _prepareParams(object, "member"));
    }
    return future.then((response) => response["data"]);
  }

  Future<Params> delete(Model object) {
    var future = request.delete(buildUri("member", object.id));
    return future.then((response) => response["data"]);
  }

  ChangeableUri buildUri(String type, [int id]) {
    var path;
    if (type.toLowerCase() == "collection") {
      path = _uriPrefix;
    } else {
      path = "${_uriPrefix}${id == null ? '' : "/$id"}";
    }
    return new ChangeableUri.fromUri(new Uri(path: path));
  }

  Params _prepareParams(Model object, [String type]) {
    var params = object.toParams(type);
    var id = params.remove("id");
    var result = {};
    if (type == "collection" && id != null) {
      result["id"] = id;
    }
    result[resourceName] = params;
    return result;
  }

  String get _uriPrefix => "/${resourceCollectionName}";
}
