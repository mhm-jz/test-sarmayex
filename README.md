# Sarmayex Realtime Markets

A Flutter trading screen that consumes realtime market and order book data from
the Sarmayex SSE endpoint.

The app opens an SSE stream for the selected market, displays a horizontal
market list, and updates the selected market order book in realtime.

## Features

- Realtime market list updates from SSE `markets` events
- Realtime order book updates from SSE `order_book` events
- Market switching with subscription cancellation
- Automatic SSE reconnect with exponential backoff and jitter
- Idle connection detection
- Retry/update action when the connection fails
- Keeps the latest order book snapshot visible during reconnecting states
- Clean Architecture style separation between data, domain, and presentation
- Bloc-based state management
- `Equatable`-based equality for entities/events/view models where useful

## Tech Stack

- Flutter
- Dart
- bloc
- flutter_bloc
- get_it
- equatable

## Architecture

```text
lib/
  core/
    constants/          API constants
    di/                 get_it dependency setup
    errors/             SSE/domain exception types
    network/sse/        manual SSE client, connection, parser, retry policy
    result/             Result success/failure wrapper

  features/
    data/
      datasources/      SSE datasource
      models/           API/data models
      mapper/           model-to-entity and exception-to-failure mappers
      repositories/     repository implementation

    domain/
      entities/         domain entities
      failures/         domain failures
      repositories/     repository contract
      usecases/         watch trading use case

    presentation/
      bloc/             TradingBloc, events, state
      mapper/           failure-to-message mapper
      pages/            trading page
      widgets/          market list, order book, status banner
```

## Realtime Flow

```text
HttpSseConnection
  -> SseClientImpl
  -> TradingSseRemoteDatasource
  -> TradingRepositoryImpl
  -> WatchTradingUseCase
  -> TradingBloc
  -> MarketsWidget / OrderBookWidget
```

The datasource parses SSE envelopes into data models. The repository maps data
models into domain entities. The Bloc owns UI state, selected market, retry
handling, and throttled order book emissions.

## SSE Behavior

- `connectionTimeout` limits how long opening the HTTP SSE connection can take.
- `idleTimeout` limits how long an open stream can stay silent before being
  treated as stale and reconnected.
- Retry uses exponential backoff: 1s, 2s, 4s, 8s, then capped at 10s, with
  jitter.

The SSE layer logs only:

- API connection attempts
- retry scheduling
- SSE errors
- market update events

Order book event lines are intentionally not logged to avoid noisy output.

## UI States

- First load:
  - Market list shows a loading indicator until market data arrives.
  - Order book area stays hidden until loading or data is available.

- First failure with no data:
  - Market list shows an error message.
  - Order book header and empty book rows are hidden.

- Failure after data:
  - Last order book snapshot remains visible.
  - Status banner shows an update/retry action.

## Getting Started

Install dependencies:

```sh
flutter pub get
```

Run the app:

```sh
flutter run
```

## Notes

- The SSE implementation is manual and does not rely on a package-level SSE
  client.
- `SseTradingEnvelopeModel` is a transport model only and is not mapped to a
  domain entity.
- `TradingRealtimeModel` conversion lives in `data/mapper` via
  `TradingRealtimeModelMapper`.
