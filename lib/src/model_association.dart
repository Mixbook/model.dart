library model.model_association;

import 'dart:async';
import 'package:model/src/params.dart';
import 'package:model/src/model.dart';
import 'package:model/src/model_connector.dart';
import 'dart:collection';

abstract class ModelAssociation<E> extends ListBase<E> {
  final Model parent;
  List<E> items = [];
  ModelConnector _connector;

  ModelAssociation(this.parent, List<Params> paramsList) {
    paramsList.forEach((params) {
      items.add(connector.buildModel(params));
    });
  }

  ModelConnector get connector {
    if (_connector == null) {
      _connector = buildConnector();
    }
    return _connector;
  }

  E find(int id) {
    return connector.find(id);
  }

  Future<List<E>> load() {
    var futures = items.map((i) => i.load());
    return Future.wait(futures).then((results) => !results.any((e) => !e));
  }

  void forEach(void f(E element)) {
    load().then((_) => items.forEach(f));
  }

  ModelConnector buildConnector();

  // List extension methods - START
  int get length => items.length;
  void set length(int length) => items.length = length;
  void operator[]=(int index, E value) => items[index] = value;
  E operator [](int index) => items[index];
  // List extension methods - END
}
