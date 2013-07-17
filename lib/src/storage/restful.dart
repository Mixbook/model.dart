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

  Future<Map<String, Object>> find(int id, [Map<String, Object> params]) {
    var future = request.get(buildUri("member", id), params);
    return future.then((response) => response["data"]);
  }

  Future<List<Map<String, Object>>> findAll([Map<String, Object> params]) {
    var future = request.get(buildUri("collection"), params);
    return future.then((response) => response["data"]);
  }

  Future<Map<String, Object>> save(Model object) {
    var future;
    if (object.isNewRecord) {
      future = request.post(buildUri("collection"), _prepareParams(object));
    } else {
      future = request.put(buildUri("member", object.id), _prepareParams(object, "member"));
    }
    return future
        .then((response) => response["data"])
        .catchError((response) => throw response['error']);
  }

  Future<Map<String, Object>> delete(Model object) {
    var future = request.delete(buildUri("member", object.id));
    return future.then((response) => response["data"]);
  }

  MutableUri buildUri(String type, [int id]) {
    var path;
    if (type.toLowerCase() == "collection") {
      path = _uriPrefix;
    } else {
      path = "${_uriPrefix}${id == null ? '' : "/$id"}";
    }
    return new MutableUri.fromUri(new Uri(path: path));
  }

  Map<String, Object> _prepareParams(Model object, [String type]) {
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
