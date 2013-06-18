library model.model_factory;

import 'package:model/src/request.dart';
import 'package:model/src/storage.dart';

abstract class ModelFactory<M> {
  Storage storage;
  Request request;

  Future<M> find(id) {
    return storage.find(id).then(buildModel);
  }

  Future<List<M>> collection([Params params]) {
    return storage.collection(params).then((paramsList) => paramsList.map(buildModel));
  }

  M buildModel(Params params);
}