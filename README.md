# Dart SSE

Dart package to help consume Server Sent Events

Forked from (https://github.com/pratikbaid3/flutter_client_sse)[https://github.com/pratikbaid3/flutter_client_sse]

### Features:
* Consumes server sent events
* Returns parsed model of the event, id and the data

## Getting Started

```dart
///GET REQUEST
SSEClient.subscribeToSSE(
    method: SSERequestType.GET,
    url:
    'http://192.168.1.2:3000/api/activity-stream?historySnapshot=FIVE_MINUTE',
    header: {
        "Cookie":
        'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict',
        "Accept": "text/event-stream",
        "Cache-Control": "no-cache",
    }).listen((event) {
        print('Id: ' + event.id!);
        print('Event: ' + event.event!);
        print('Data: ' + event.data!);
    },
);

///POST REQUEST
SSEClient.subscribeToSSE(
    method: SSERequestType.POST,
    url:
    'http://192.168.1.2:3000/api/activity-stream?historySnapshot=FIVE_MINUTE',
    header: {
        "Cookie":
        'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict',
        "Accept": "text/event-stream",
        "Cache-Control": "no-cache",
    },
    body: {
        "name": "Hello",
        "customerInfo": {"age": 25, "height": 168}
    }).listen((event) {
            print('Id: ' + event.id!);
            print('Event: ' + event.event!);
            print('Data: ' + event.data!);
    },
);
```

## Running Sample Backend

[Nest](https://github.com/nestjs/nest) The backend is in NestJS serving a single SSE api.

## Installation

```bash
$ yarn install
```

## Running the app

```bash
# development
$ yarn run start

# watch mode
$ yarn run start:dev
```
