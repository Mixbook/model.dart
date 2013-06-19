part of model_tests;

class LocalStorageMock {
  String identifier = "123";
  int id;
  String name;

  LocalStorageMock.fromParams(Params params) {
    id = params["id"];
    name = params["name"];
  }

  Params toParams() {
    return {"id": id, "name": name};
  }
}


void localStorageTest() {
  group("Local Storage tests:", () {
    LocalStorage storage;

    setUp(() {
      html.window.localStorage.clear();
      storage = new LocalStorage((Params params) {
        return new LocalStorageMock.fromParams(params);
      });
    });

    tearDown(() {
      html.window.localStorage.clear();
    });

    test("find an object", () {
      html.window.localStorage["123"] = json.stringify({"id": "433", "name": "New one"});
      var object = storage.find("123");
      expect(object.id, equals("433"));
      expect(object.name, equals("New one"));
    });

    test("save an object", () {
      var object = new LocalStorageMock.fromParams({"id": "234", "name": "Bla"});
      storage.save(object);
      expect(html.window.localStorage["123"], equals('{"id":"234","name":"Bla"}'));
    });

    test("delete an object", () {
      html.window.localStorage["123"] = "blabla";
      var object = new LocalStorageMock.fromParams({"id": "234", "name": "Foo"});
      storage.delete(object);
      expect(storage.find("123"), equals(null));
    });
  });
}

