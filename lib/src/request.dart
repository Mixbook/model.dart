library model.request;

import 'dart:json' as json;
import 'dart:html';
import 'dart:async';
import 'dart:collection';
import 'package:model/src/params.dart';
import 'package:model/src/changeable_uri.dart';

class Request {
  String _host;
  int _port;
  String _scheme;
  String _pathPrefix;

  Request(this._host, this._port, this._scheme, this._pathPrefix);

  Future<Params> get(ChangeableUri uri, [Params params, HttpRequest xhr]) {
    if (params != null) {
      uri.addParameters(_getNotNullParams(params));
    }
    return _request(uri, "GET", null, xhr);
  }

  Future<Params> post(ChangeableUri uri, Params params, [HttpRequest xhr]) {
    return _request(uri, "POST", new Map.from(params), xhr);
  }

  Future<Params> put(ChangeableUri uri, Params params, [HttpRequest xhr]) {
    var data = new HashMap.from(params)..addAll({"_method": "PUT"});
    return _request(uri, "PUT", data, xhr);
  }

  Future<Params> delete(ChangeableUri uri, [Params params, HttpRequest xhr]) {
    if (params == null) {
      params = {};
    }
    var data = new HashMap.from(params)..addAll({"_method": "DELETE"});
    return _request(uri, "DELETE", data, xhr);
  }


  void _adjustUri(uri) {
    uri.host = _host;
    uri.port = _port;
    uri.scheme = _scheme;
    uri.path = _pathPrefix.replaceFirst(new RegExp(r'^/'), "") + uri.path;
  }

  Future<Params> _request(ChangeableUri uri, String method, [Params sendData, HttpRequest xhr]) {
    _adjustUri(uri);
    var jsonData = sendData != null ? json.stringify(sendData) : null;

    var completer = new Completer();

    if (xhr == null) {
      xhr = new HttpRequest();
    }

    xhr.open(method, uri.toString());
    xhr.setRequestHeader("Content-Type", "application/json");
    // TODO: Need to add checking for response["errors"] and sending it into completer
    xhr.onLoad.listen((e) {
      if ((xhr.status >= 200 && xhr.status < 300) || xhr.status == 0 || xhr.status == 304) {
         completer.complete(xhr);
      } else {
         completer.completeError(e);
      }
    });
    xhr.onError.listen((e) {
      completer.completeError(e);
    });
    if (jsonData != null) {
      xhr.send(jsonData);
    } else {
      xhr.send();
    }

    return completer.future.then((xhr) => json.parse(xhr.response));
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
