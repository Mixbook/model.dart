library model.changeable_uri;

import 'package:model/src/params.dart';

// TODO: A little weird name... Try to think of something better?
class ChangeableUri {
  String host;
  int port;
  String path;
  String scheme;
  Params queryParameters = {};

  final int hashCode;

  ChangeableUri.fromUri(Uri uri) :
      hashCode = uri.hashCode
  {
    host = uri.host;
    port = uri.port;
    path = uri.path;
    scheme = uri.scheme;
    queryParameters = new Map.from(uri.queryParameters);
  }

  bool operator ==(ChangeableUri other) {
    return hashCode == other.hashCode;
  }

  factory ChangeableUri.fromString(String input) {
    return new ChangeableUri.fromUri(Uri.parse(input));
  }

  Uri toUri() {
    return new Uri(
        scheme: scheme, host: host, port: port,
        path: path, queryParameters: (queryParameters as Map<String, String>));
  }
  String toString() => toUri().toString();

  void addParameters(params) {
    if (params is String) {
      params.replaceFirst(new RegExp(r'^\?'), '').split("&").forEach((keyValue) {
        var keyValueArray = keyValue.split("=");
        var key = keyValueArray[0];
        var value = keyValueArray[1];
        if (key.contains("[]")) {
          queryParameters[key] = queryParameters[key] == null ? queryParameters[key] : [];
          (queryParameters[key] as List).add(value);
        } else {
          queryParameters[key] = value;
        }
      });
    } else if (params is Map<String, String>) {
      // TODO: Map.merge will be added very soon, will need to replace that
      params.forEach((key, value) {
        queryParameters[key] = value;
      });
    } else {
      throw "'params' argument should be String or Map<String, String>";
    }
  }

  void removeParameters(List<String> keys) {
    keys.forEach((k) => queryParameters.remove(k));
  }
}
