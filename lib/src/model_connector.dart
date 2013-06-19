library model.model_connector;

import 'dart:async';
import 'package:model/src/model.dart';
import 'package:model/src/params.dart';
import 'package:model/src/request.dart';
import 'package:model/src/storage.dart';

abstract class ModelConnector {
  AsyncStorage storage;
  Request request;

  Future<Model> find(int id) {
    return storage.find(id).then(buildModel);
  }

  Future<List<Model>> findAll([Params params]) {
    return storage.findAll(params).then((paramsList) => paramsList.map(buildModel));
  }

  Model buildModel(Params params);
}
