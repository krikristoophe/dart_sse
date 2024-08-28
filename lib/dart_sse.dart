library dart_sse;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
part 'sse_event_model.dart';

/// Request type
enum SSERequestType {
  /// Get request
  get,

  /// Post request
  post;

  /// Get method from enum
  String get method => name.toUpperCase();
}

/// Stream listen callback type
typedef StreamListenCallback<T> = StreamSubscription<T> Function(
  void Function(T event)? onData, {
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
});

/// A client for subscribing to Server-Sent Events (SSE).
class SSEClient {
  ///
  SSEClient({
    this.authenticate,
  });
  http.Client _client = http.Client();
  final StreamController<SSEModel> _streamController =
      StreamController.broadcast();

  /// Authenticate request callback
  final Future<http.Request> Function(http.Request request)? authenticate;

  /// Listen stream
  StreamListenCallback<SSEModel> get listen => _streamController.stream.listen;

  /// Retry the SSE connection after a delay.
  ///
  /// [method] is the request method (GET or POST).
  /// [url] is the URL of the SSE endpoint.
  /// [headers] is a map of request headers.
  /// [body] is an optional request body for POST requests.
  void _retryConnection({
    required SSERequestType method,
    required String url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    Future.delayed(const Duration(seconds: 5), () {
      _resetHttpClient();
      subscribeToSSE(
        method: method,
        url: url,
        headers: headers,
        body: body,
      );
    });
  }

  Future<http.Request> Function(http.Request request)
      get _authenticationCallback =>
          authenticate ?? (request) => Future.value(request);

  /// Subscribe to Server-Sent Events.
  ///
  /// [method] is the request method (GET or POST).
  /// [url] is the URL of the SSE endpoint.
  /// [headers] is a map of request headers.
  /// [body] is an optional request body for POST requests.
  ///
  /// Returns a [Stream] of [SSEModel] representing the SSE events.
  Stream<SSEModel> subscribeToSSE({
    required SSERequestType method,
    required String url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    final lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');
    SSEModel currentSSEModel = SSEModel(data: '', id: '', event: '');

    try {
      final http.Request request = http.Request(
        method.method,
        Uri.parse(url),
      );

      /// Adding headers to the request
      request.headers.addAll(headers);

      /// Adding body to the request if exists
      if (body != null) {
        request.body = jsonEncode(body);
      }

      _authenticationCallback(request).then((authenticatedRequest) {
        final Future<http.StreamedResponse> response =
            _client.send(authenticatedRequest);

        /// Listening to the response as a stream
        response.asStream().listen(
          (data) {
            /// Applying transforms and listening to it
            data.stream
                .transform(const Utf8Decoder())
                .transform(const LineSplitter())
                .listen(
              (dataLine) {
                if (dataLine.isEmpty) {
                  /// This means that the complete event set has been read.
                  /// We then add the event to the stream
                  _streamController.add(currentSSEModel);
                  currentSSEModel = SSEModel(data: '', id: '', event: '');
                  return;
                }

                /// Get the match of each line through the regex
                final Match match = lineRegex.firstMatch(dataLine)!;
                final field = match.group(1);
                if (field!.isEmpty) {
                  return;
                }
                late final String value;
                if (field == 'data') {
                  // If the field is data,
                  // we get the data through the substring
                  value = dataLine.substring(5);
                } else {
                  value = match.group(2) ?? '';
                }
                switch (field) {
                  case 'event':
                    currentSSEModel.event = value;
                  case 'data':
                    currentSSEModel.data =
                        '${currentSSEModel.data ?? ''}$value\n';
                  case 'id':
                    currentSSEModel.id = value;
                  case 'retry':
                    break;
                  default:
                    _retryConnection(
                      method: method,
                      url: url,
                      headers: headers,
                    );
                }
              },
              onError: (e, s) {
                _retryConnection(
                  method: method,
                  url: url,
                  headers: headers,
                  body: body,
                );
              },
            );
          },
          onError: (e, s) {
            _retryConnection(
              method: method,
              url: url,
              headers: headers,
              body: body,
            );
          },
        );
      });
    } catch (e) {
      _retryConnection(
        method: method,
        url: url,
        headers: headers,
        body: body,
      );
    }
    return _streamController.stream;
  }

  /// Close client
  /// Client cant be used after close
  Future<void> close() async {
    _resetHttpClient();
    await _streamController.close();
  }

  void _resetHttpClient() {
    _client.close();
    _client = http.Client();
  }
}
