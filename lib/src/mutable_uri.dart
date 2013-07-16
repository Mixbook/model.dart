library model.mutable_uri;

class MutableUri implements Uri {
  String host;
  int port;
  String path;
  String scheme;
  Map<String, Object> queryParameters = {};

  final int hashCode;

  MutableUri.fromUri(Uri uri) :
      hashCode = uri.hashCode
  {
    host = uri.host;
    port = uri.port;
    path = uri.path;
    scheme = uri.scheme;
    queryParameters = new Map.from(uri.queryParameters);
  }

  bool operator ==(MutableUri other) {
    return hashCode == other.hashCode;
  }

  factory MutableUri.fromString(String input) {
    return new MutableUri.fromUri(Uri.parse(input));
  }

  Uri toUri() {
    return new Uri(
        scheme: scheme, host: host, port: port,
        path: path, queryParameters: queryParameters);
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

  /* Delegating to Uri to provide its interface */

  List<String> get pathSegments => toUri().pathSegments;
  Uri resolve(String uri) => toUri().resolve(uri);
  String get userInfo => toUri().userInfo;
  String get query => toUri().query;
  String get authority => toUri().authority;
  String get origin => toUri().origin;
  String get fragment => toUri().origin;
  Uri resolveUri(Uri reference) => toUri().resolveUri(reference);
  bool get hasAuthority => toUri().hasAuthority;
  bool get isAbsolute => toUri().scheme;
}
