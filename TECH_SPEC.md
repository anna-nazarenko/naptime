# Naptime — Technical specification

## Stack

- iOS 17+
- watchOS 10+
- SwiftUI
- SwiftData (recommended for MVP)
- WatchConnectivity

## Architecture

Recommended architecture: **MVVM + Services + Domain layer**.

### Layers

- **Shared Domain**
  - entities
  - validation rules
  - metrics logic
  - sync payloads
- **Persistence layer**
  - repository interfaces
  - SwiftData implementation
- **Feature layer**
  - Today
  - Sessions
  - Week
  - Settings
- **Platform services**
  - WatchConnectivity
  - time provider

## Source of truth

For MVP, iPhone is the primary source of truth.

The watch can send commands and receive state updates.

## Core domain rules

### Active session invariant

Only one active session may exist at a time.

### Validation

- `endAt > startAt`
- no overlap with any existing session except the one being edited

### Sleep day

The user defines the start of a sleep day, for example 06:00.
A sleep day runs from `dayStart` to the same time on the next calendar day.

### Metrics

For accurate daily totals, sessions should be sliced by sleep-day boundaries.
Metrics must be calculated from the intersected segment inside a day window.

## Sync

### Commands Watch -> iPhone

- `startSleep(timestamp, commandId)`
- `stopSleep(timestamp, commandId)`

### State iPhone -> Watch

- current active session state
- today's total
- today's session count
- last updated timestamp

### Reliability

Commands should be idempotent using `commandId`.

## Edge cases

- duplicate Start tap
- Stop with no active session
- app relaunch while a session is active
- timezone or DST change
- session crossing sleep-day boundary
- simultaneous iPhone and Watch actions

## Testing strategy

### Unit tests

- overlap detection
- day slicing
- daily metrics
- active session rules

### Integration tests

- repository CRUD
- persistence restore
- basic sync flow with mocks

