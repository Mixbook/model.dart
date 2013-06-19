library model.storage;

import 'dart:html' as html;
import 'dart:json' as json;
import 'dart:async';
import 'package:model/src/params.dart';
import 'package:model/src/request.dart';
import 'package:model/src/changeable_uri.dart';

part 'storage/local.dart';
part 'storage/restful.dart';

abstract class Storage<E> {
}

abstract class SyncStorage<E> extends Storage<E> {
  E find(Params params);
  bool save(E object);
  bool delete(E object);
}

abstract class AsyncStorage<E> extends Storage<E> {
  Future<E> find(int id, [Params params]);
  Future<List<E>> findAll([Params params]);
  Future<Params> save(E object);
  Future<Params> delete(E object);
}
