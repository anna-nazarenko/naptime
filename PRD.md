# Naptime — PRD for MVP

## Product goal

Naptime helps parents track a child's sleep with minimal friction on **iPhone** and **Apple Watch**.

The MVP should make three core jobs easy:

1. Start and stop a sleep session in one or two taps.
2. Manually add or fix sessions when the parent forgot to track live.
3. Show clear daily and weekly sleep summaries.

Child profile management is explicitly deferred beyond MVP.

## Problem

Parents often track sleep in notes, spreadsheets, or overly broad baby-tracking apps. The main pain points are slow interaction, poor editing flows, and low trust in daily totals.

## Target audience

Primary audience: parents/caregivers of children aged 0–3 years.

## MVP scope

### In scope

- Start/stop sleep on iPhone
- Start/stop sleep on Apple Watch
- Manual add/edit/delete sleep session
- Daily summary
- Weekly summary
- Configurable “sleep day start” (for example, 06:00)
- Local storage only

### Out of scope

- Child profile setup/customization (including child name)
- Multiple children
- Cloud sync/accounts
- HealthKit integration
- Automatic sleep detection
- Feeding/diaper/growth tracking
- Partner sharing
- Advanced recommendations

## Primary user stories

- As a parent, I want to tap Start Sleep so that I can log a sleep session immediately.
- As a parent, I want to tap Stop Sleep so that the session is saved.
- As a parent, I want to add a session manually if I forgot to start tracking.
- As a parent, I want to edit or delete a session if it was logged incorrectly.
- As a parent, I want to see daily totals and weekly summaries.
- As a parent, I want to start and stop sleep from Apple Watch.

## Success metrics

- A new user records their first sleep session within the first 10 minutes.
- The average number of taps for start/stop remains very low.
- Watch-to-iPhone sync failures are rare.
- Daily totals remain consistent and trustworthy, especially for sleep that crosses midnight.

## Functional requirements

### Tracking

- The app supports exactly one active sleep session at a time.
- A sleep session has `startAt` and `endAt`.
- A session may be active when `endAt == nil`.
- Overlapping sessions are not allowed in MVP.

### Manual entry

- The user can add a sleep session for any past time.
- The user can edit start and end time.
- Validation errors must be shown in clear language.

### Daily view

- The app shows:
  - total sleep
  - number of sessions
  - total awakenings
  - session list for the selected sleep day

### Weekly view

- The app shows stats by calendar week only (Monday to Sunday).
- The user can review the current week and previous calendar weeks.
- The app shows weekly average total sleep for the selected calendar week.

### Settings

- The user can set sleep day start time.

### Watch support

- The user can start and stop sleep from Apple Watch.
- The watch shows whether sleep is currently running.
- The watch receives simple confirmation feedback.

## Non-functional requirements

- SwiftUI for UI
- SwiftData for local persistence
- Local-only storage for MVP
- Fast launch and responsive UI
- Clean architecture that supports future sync and multi-child support

