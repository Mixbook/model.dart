library model.request;

import 'dart:json' as json;
import 'dart:html';
import 'dart:async';
import 'dart:collection';
import 'package:model/src/params.dart';
import 'package:model/src/changeable_uri.dart';
import 'package:model/src/http_request_mock.dart';

class Request {
  String _host;
  int _port;
  String _scheme;
  String _pathPrefix;
  HttpRequest _xhr;

  Request(this._host, this._port, this._scheme, this._pathPrefix, [HttpRequest xhr]) {
    if (xhr == null) {
      _xhr = new HttpRequest();
    } else {
      _xhr = xhr;
    }
  }

  Future<Params> get(ChangeableUri uri, [Params params]) {
    if (params != null) {
      uri.addParameters(_getNotNullParams(params));
    }
    return _request(uri, "GET");
  }

  Future<Params> post(ChangeableUri uri, Params params) {
    return _request(uri, "POST", new Map.from(params));
  }

  Future<Params> put(ChangeableUri uri, Params params) {
    var data = new HashMap.from(params)..addAll({"_method": "PUT"});
    return _request(uri, "PUT", data);
  }

  Future<Params> delete(ChangeableUri uri, [Params params]) {
    if (params == null) {
      params = {};
    }
    var data = new HashMap.from(params)..addAll({"_method": "DELETE"});
    return _request(uri, "DELETE", data);
  }


  void _adjustUri(uri) {
    uri.host = _host;
    uri.port = _port;
    uri.scheme = _scheme;
    uri.path = _pathPrefix.replaceFirst(new RegExp(r'^/'), "") + uri.path;
  }

  Future<Params> _request(ChangeableUri uri, String method, [Params sendData]) {
    _adjustUri(uri);
    var jsonData = sendData != null ? json.stringify(sendData) : null;

    var completer = new Completer();
    _xhr.open(method, uri.toString());
    _xhr.setRequestHeader("Content-Type", "application/json");
    // TODO: Need to add checking for response["errors"] and sending it into completer
    _xhr.onLoad.listen((e) {
      if ((_xhr.status >= 200 && _xhr.status < 300) || _xhr.status == 0 || _xhr.status == 304) {
         completer.complete(_xhr);
      } else {
         completer.completeError(e);
      }
    });
    _xhr.onError.listen((e) {
      completer.completeError(e);
    });
    if (jsonData != null) {
      _xhr.send(jsonData);
    } else {
      _xhr.send();
    }

    return completer.future.then((_xhr) => json.parse(_xhr.response));
  }

  Params _getNotNullParams(params) {
    var notNullParams = {};
    (params != null ? params : {}).forEach((k, v) {
      if (v != null) {
        notNullParams[k] = v;
      }
    });
    return notNullParams;
  }
}
