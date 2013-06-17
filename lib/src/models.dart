class Models {
  List<ModelFactory> _factories = [];

  void register(ModelFactory fact) {
    _factories.add(fact);
  }

  ModelFactory get(Type modelType) {
    return _factories.firstWhere((e) => e.matches(modelType));
  }
}
