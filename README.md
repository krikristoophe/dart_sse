# Dart SSE

Dart package to help consume Server Sent Events

Forked from (https://github.com/pratikbaid3/flutter_client_sse)[https://github.com/pratikbaid3/flutter_client_sse]

### Features:
* Consumes server sent events
* Returns parsed model of the event, id and the data

## Getting Started

### Get request

```dart
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
```

### Post request
```dart
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
```

### Authenticate

`SSEClient` can be provided with `authenticate` method. This method allow to mutate the http request with anything before sending.

This callback is called before all request, even on retry. If an error is thrown, the authenticate will be called again. In case of error related to a refresh token, you can update the token before sending reconnecting to SSE.

## Running Sample Backend

[Nest](https://github.com/nestjs/nest) The backend is in NestJS serving a single SSE api.

### Installation

```bash
$ yarn install
```

### Running the app

```bash
# development
$ yarn run start

# watch mode
$ yarn run start:dev
```

### Run the example

```sh
dart run example/main.dart
```
