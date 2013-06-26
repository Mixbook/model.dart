library model.model_association;

import 'dart:async';
import 'package:model/src/params.dart';
import 'package:model/src/model.dart';
import 'package:model/src/model_connector.dart';
import 'dart:collection';

abstract class ModelAssociation<E> extends ListBase<E> {
  final Model parent;
  List<E> _items = [];
  ModelConnector _connector;

  ModelAssociation(this.parent, List<Params> paramsList) {
    paramsList.forEach((params) {
      _items.add(connector.buildModel(params));
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
    var futures = _items.map((i) => i.load());
    return Future.wait(futures).then((results) => !results.any((e) => !e));
  }

  Future forEach(void f(E element)) {
    return load().then((_) => _items.forEach(f));
  }

  ModelConnector buildConnector();

  // List extension methods - START
  int get length => _items.length;
  set length(int length) => _items.length = length;
  
  void operator []=(int index, E value) {
    _items[index] = value;
  }
  
  E operator [](int index) => _items[index];
  // List extension methods - END
}
