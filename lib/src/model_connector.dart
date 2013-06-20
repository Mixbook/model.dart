library model.model_connector;

import 'dart:async';
import 'package:model/src/model.dart';
import 'package:model/src/params.dart';
import 'package:model/src/request.dart';
import 'package:model/src/storage.dart';

abstract class ModelConnector<E> {
  AsyncStorage storage;
  Request request;

  Future<E> find(int id) {
    return storage.find(id).then(buildModel);
  }

  Future<List<E>> findAll([Params params]) {
    return storage.findAll(params).then((paramsList) => paramsList.map(buildModel));
  }

  E buildModel(Params params);
}
