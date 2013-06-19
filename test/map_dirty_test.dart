part of model_tests;

void mapDirtyTest() {
  group("MapDirty tests:", () {
    MapDirty map;
    setUp(() {
      map = new MapDirty.from({"a": 1, "b": "c", "d": [1,2,3]});
    });

    test("change a value", () {
      map["a"] = 2;
      expect(map.summaryChanges["a"], equals(2));
    });

    test("delete a value", () {
      map.remove("b");
      expect(map.summaryChanges["b"], equals(null));
    });

    test("add a value", () {
      map["e"] = 5;
      expect(map.summaryChanges["e"], equals(5));
    });
  });
}
