part of model_tests;

class RestfulStorageObject {
  String identifier = "123";
  int id;
  String name;
  bool get isNewRecord => null == id;

  RestfulStorageObject(Params params) {
    id = params["id"];
    name = params["name"];
  }

  Params toParams([String type]) {
    return {"id": id, "name": name, "type": (type == null ? "create" : "update")};
  }
}

class RequestMock extends Mock implements Request {}

void restfulStorageTest() {
  group("Restful Storage tests:", () {
    RestfulStorage<RestfulStorageObject> storage;
    RequestMock requestMock;

    setUp(() {
      requestMock = new RequestMock();
      storage = new RestfulStorage<RestfulStorageObject>(requestMock, "project", "projects");
    });

    test("find an object", () {
      var uri = new ChangeableUri.fromString("/projects/123");
      requestMock.when(callsTo('get', uri, null)).alwaysReturn(new Future(() {
        return {"data": {"id": "123", "name": "Big one"}};
      }));
      storage.find(123).then(expectAsync1((obj) {
        expect(obj["id"], equals("123"));
        expect(obj["name"], equals("Big one"));
      }));
    });

    test("retrieve a collection", () {
      var uri = new ChangeableUri.fromString("/projects");
      requestMock.when(callsTo('get', uri, null)).alwaysReturn(new Future(() {
        return {"data": [{"id": "1", "name": "One"}, {"id": "2", "name": "Two"}]};
      }));
      storage.findAll().then(expectAsync1((objects) {
        expect(objects[0]["id"], equals("1"));
        expect(objects[0]["name"], equals("One"));
        expect(objects[1]["id"], equals("2"));
        expect(objects[1]["name"], equals("Two"));
      }));
    });

    test("create an object", () {
      var uri = new ChangeableUri.fromString("/projects");
      requestMock.
          when(callsTo('post', uri, {"project": {"name": "Bla", "type": "create"}})).
          alwaysReturn(new Future(() => {"data": {"name": "New name"}, "errors": []}));
      var object = new RestfulStorageObject({"name": "Bla"});
      storage.save(object).then(expectAsync1((params) {
        expect(params, {'name': 'New name'});
      }));
    });

    test("update an object", () {
      var uri = new ChangeableUri.fromString("/projects/123");
      requestMock.
          when(callsTo('put', uri, {"project": {"name": "Bla", "type": "update"}})).
          alwaysReturn(new Future(() => {"data": {"name": "New name"}, "errors": []}));
      var object = new RestfulStorageObject({"id": "123", "name": "Bla"});
      storage.save(object).then(expectAsync1((params) {
        expect(params, {'name': 'New name'});
      }));
    });

    test("delete an object", () {
      var uri = new ChangeableUri.fromString("/projects/123");
      requestMock.
          when(callsTo('delete', uri)).
          alwaysReturn(new Future(() => {"data": {}, "errors": []}));
      var object = new RestfulStorageObject({"id": "123", "name": "Bla"});
      storage.delete(object).then(expectAsync1((params) {
        expect(params, {});
      }));
    });
  });
}
