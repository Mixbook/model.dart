import 'dart:html';
import 'dart:json' as json;

class HttpRequestMaybeMock {
  static var useMock = false;

  factory HttpRequestMaybeMock() {
    if (HttpRequestMaybeMock.useMock) {
      return new HttpRequestMock();
    } else {
      return new HttpRequest();
    }
  }
}

class HttpRequestMock {
  String method;
  String uri;
  Object data;
  Map<String, String> requestHeaders = {};
  int status = 200;
  _EventsMock onLoad = new _EventsMock();
  _EventsMock onError = new _EventsMock();

  void open(String method, String uri) {
    this.method = method;
    this.uri = uri;
  }

  void send([data]) {
    this.data = data;
    onLoad.events.forEach((c) => c(new Object()));
  }

  void setRequestHeader(String header, String value) {
    requestHeaders[header] = value;
  }

  String get response {
    return json.stringify({
        "requestHeaders": requestHeaders, "method": method,
        "uri": uri, "data": data, "status": status});
  }
}

class _EventsMock {
  List<Function> events = [];
  void listen(Function callback) {
    events.add(callback);
  }
}
