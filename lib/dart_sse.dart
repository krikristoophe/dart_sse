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

/// A client for subscribing to Server-Sent Events (SSE).
class SSEClient {
  static http.Client _client = http.Client();

  /// Retry the SSE connection after a delay.
  ///
  /// [method] is the request method (GET or POST).
  /// [url] is the URL of the SSE endpoint.
  /// [header] is a map of request headers.
  /// [body] is an optional request body for POST requests.
  /// [streamController] is required to persist
  /// the stream from the old connection
  static void _retryConnection({
    required SSERequestType method,
    required String url,
    required Map<String, String> header,
    required StreamController<SSEModel> streamController,
    Map<String, dynamic>? body,
  }) {
    Future.delayed(const Duration(seconds: 5), () {
      subscribeToSSE(
        method: method,
        url: url,
        header: header,
        body: body,
        oldStreamController: streamController,
      );
    });
  }

  /// Subscribe to Server-Sent Events.
  ///
  /// [method] is the request method (GET or POST).
  /// [url] is the URL of the SSE endpoint.
  /// [header] is a map of request headers.
  /// [body] is an optional request body for POST requests.
  ///
  /// Returns a [Stream] of [SSEModel] representing the SSE events.
  static Stream<SSEModel> subscribeToSSE({
    required SSERequestType method,
    required String url,
    required Map<String, String> header,
    StreamController<SSEModel>? oldStreamController,
    Map<String, dynamic>? body,
  }) {
    StreamController<SSEModel> streamController = StreamController();
    if (oldStreamController != null) {
      streamController = oldStreamController;
    }
    final lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');
    var currentSSEModel = SSEModel(data: '', id: '', event: '');
    while (true) {
      try {
        _client = http.Client();
        final request = http.Request(
          method.method,
          Uri.parse(url),
        );

        /// Adding headers to the request
        header.forEach((key, value) {
          request.headers[key] = value;
        });

        /// Adding body to the request if exists
        if (body != null) {
          request.body = jsonEncode(body);
        }

        final Future<http.StreamedResponse> response = _client.send(request);

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
                  streamController.add(currentSSEModel);
                  currentSSEModel = SSEModel(data: '', id: '', event: '');
                  return;
                }

                /// Get the match of each line through the regex
                final Match match = lineRegex.firstMatch(dataLine)!;
                final field = match.group(1);
                if (field!.isEmpty) {
                  return;
                }
                var value = '';
                if (field == 'data') {
                  // If the field is data,
                  // we get the data through the substring
                  value = dataLine.substring(
                    5,
                  );
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
                      header: header,
                      streamController: streamController,
                    );
                }
              },
              onError: (e, s) {
                _retryConnection(
                  method: method,
                  url: url,
                  header: header,
                  body: body,
                  streamController: streamController,
                );
              },
            );
          },
          onError: (e, s) {
            _retryConnection(
              method: method,
              url: url,
              header: header,
              body: body,
              streamController: streamController,
            );
          },
        );
      } catch (e) {
        _retryConnection(
          method: method,
          url: url,
          header: header,
          body: body,
          streamController: streamController,
        );
      }
      return streamController.stream;
    }
  }

  /// Unsubscribe from the SSE.
  static void unsubscribeFromSSE() {
    _client.close();
  }
}
