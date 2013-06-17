part of model_tests;

class Model1 extends Model {}
class Model1Factory extends ModelFactory {
  bool matches(Model m) => m == Model1;
}

class Model2 extends Model {}
class Model2Factory extends ModelFactory {
  bool matches(Model m) => m == Model2;
}

void modelsTest() {
  group("Models tests:", () {
    Models models;

    setUp(() {
      models = new Models();
    });

    test("get right factory", () {
      var factory1 = new Model1Factory();
      var factory2 = new Model2Factory();
      models.register(factory1);
      models.register(factory2);
      expect(models.get(Model2), equals(factory2));
    });
  });
}
