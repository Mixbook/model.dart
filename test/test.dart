library model_tests;

import 'dart:html' as html;
import 'dart:json' as json;
import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:unittest/html_config.dart';

import 'package:model/model.dart';
import 'package:model/src/http_request_mock.dart';

part 'storage/local_test.dart';
part 'storage/restful_test.dart';
part 'request_test.dart';
part 'map_dirty_test.dart';

void main() {
  localStorageTest();
  restfulStorageTest();
  requestTest();
  mapDirtyTest();
  // TODO: Model's tests
}
