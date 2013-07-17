library model.storage;

import 'dart:html' as html;
import 'dart:json' as json;
import 'dart:async';
import 'package:model/src/request.dart';
import 'package:model/src/mutable_uri.dart';
import 'package:model/src/model.dart';

part 'storage/local.dart';
part 'storage/restful.dart';

abstract class Storage<E> {
}

abstract class SyncStorage<E> extends Storage<E> {
  E find(String identifier);
  bool save(E object);
  bool delete(E object);
}

abstract class AsyncStorage<E> extends Storage<E> {
  Request request;
  Future<Map<String, Object>> find(int id, [Map<String, Object> params]);
  Future<List<Map<String, Object>>> findAll([Map<String, Object> params]);
  Future<Map<String, Object>> save(E object);
  Future<Map<String, Object>> delete(E object);
  MutableUri buildUri(String type, [int id]);
}
