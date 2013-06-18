library model.model_association;

import 'dart:async';
import 'package:model/src/params.dart';
import 'package:model/src/model.dart';
import 'package:model/src/model_factory.dart';
import 'dart:collection';

abstract class ModelAssociation<E> extends ListBase<E> {
  final Model parent;
  List<E> items = [];
  ModelFactory _fact;

  ModelAssociation(this.parent, List<Params> paramsList) {
    paramsList.forEach((params) {
      items.add(fact.buildModel(params));
    });
  }

  ModelFactory get fact {
    if (_fact == null) {
      _fact = buildFactory();
    }
    return _fact;
  }

  E find(int id) {
    return fact.find(id);
  }

  Future<List<E>> load() {
    var futures = items.map((i) => i.load());
    return Future.wait(futures).then((results) => !results.any((e) => !e));
  }

  void forEach(void f(E element)) {
    load().then((_) => items.forEach(f));
  }

  ModelFactory buildFactory();

  // List extension methods - START
  int get length => items.length;
  void set length(int length) => items.length = length;
  void operator[]=(int index, E value) => items[index] = value;
  E operator [](int index) => items[index];
  // List extension methods - END
}
