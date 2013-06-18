library model.model_association;

import 'dart:async';
import 'package:model/src/params.dart';
import 'package:model/src/model_factory.dart';

abstract class ModelAssociation<P, E> implements List<E> {
  final _futures = new List<Future<E>>();
  final _values = new Map<K, E>();
  final P parent;
  ModelFactory _fact;

  ModelAssociation(this.parent);

  ModelFactory get fact {
    if (_fact == null) {
      _fact = buildFactory();
    }
    return _fact;
  }

  E find(int id) {
    return fact.find(id);
  }

  List<E> collection({Params params: null, bool force: false}) {
    return fact.collection(params).then((objects) {
      objects.forEach((object) => _addToValues(object, force: force));
    });
  }

  List<E> load(List<Params> paramsList, {bool force: false}) {
    paramsList.forEach((params) {
      var keys = params.keys.toList();
      // If params == {"id": something}, then we'll retrieve the record from the server
      if (keys.length == 1 && keys[0] == "id") {
        var future = fact.find(params["id"]);
        _futures.add(future);
        future.then((object) {
          _addToValues(object, force: force);
          _futures.remove(future);
        });
      } else {
        var object = fact.buildModel(params);
        _addToValues(object, force: force);
      }
    });
  }

  void forEach(void f(E element)) {
    _values.values.forEach(f);
    _futures.forEach((future) => future.then(f));
  }

  void _addToValues(E object, {bool force: false}) {
    if (force || !_values.containsKey(object.id)) {
      _values[object.id] = object;
    }
  }

  noSuchMethod(Invocation invocation) {
    return reflect(_values.values).delegate(invocation);
  }

  ModelFactory buildFactory();
}
