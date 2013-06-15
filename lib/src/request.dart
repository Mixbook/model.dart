library model.request;

import 'dart:json' as json;
import 'dart:html';
import 'dart:async';
import 'package:model/src/params.dart';
import 'package:model/src/changeable_uri.dart';
import 'package:model/src/http_request_mock.dart';

class Request {
  String host;
  int port;
  String scheme;
  String pathPrefix;

  Request(this.host, this.port, this.scheme, this.pathPrefix);

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
    var data = new Map.from(params)..addAll({"_method": "PUT"});
    return _request(uri, "PUT", data);
  }

  Future<Params> delete(ChangeableUri uri, [Params params]) {
    if (params == null) {
      params = {};
    }
    var data = new Map.from(params)..addAll({"_method": "DELETE"});
    return _request(uri, "DELETE", data);
  }


  void _adjustUri(uri) {
    uri.host = host;
    uri.port = port;
    uri.scheme = scheme;
    uri.path = pathPrefix.replaceFirst(new RegExp(r'^/'), "") + uri.path;
  }

  Future<Params> _request(ChangeableUri uri, String method, [Params sendData]) {
    _adjustUri(uri);
    var jsonData = sendData != null ? json.stringify(sendData) : null;

    var xhr = new HttpRequestMaybeMock();
    var completer = new Completer();
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
