// ignore_for_file: avoid_print

import 'package:dart_sse/dart_sse.dart';

void main() {
  // GET REQUEST

  final SSEClient getClient = SSEClient(
    authenticate: (request) async {
      request.headers['Cookie'] =
          'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict';
      return request;
    },
  );

  getClient.listen(
    (event) {
      print('Id: ${event.id ?? ''}');
      print('Event: ${event.event ?? ''}');
      print('Data: ${event.data ?? ''}');
    },
  );

  getClient.subscribeToSSE(
    method: SSERequestType.get,
    url: 'http://localhost:12000/sse',
    headers: {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    },
  );

  ///POST REQUEST
  final SSEClient postClient = SSEClient(
    authenticate: (request) async {
      request.headers['Cookie'] =
          'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict';
      return request;
    },
  );

  postClient.subscribeToSSE(
    method: SSERequestType.post,
    url:
        'http://localhost:12000/api/activity-stream?historySnapshot=FIVE_MINUTE',
    headers: {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    },
    body: {
      'name': 'Hello',
      'customerInfo': {'age': 25, 'height': 168},
    },
  ).listen(
    (event) {
      print('Id: ${event.id!}');
      print('Event: ${event.event!}');
      print('Data: ${event.data!}');
    },
  );
}
