//
//  TodayViewModel.swift
//  Naptime
//
//  Created by Codex on 26/08/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class TodayViewModel {
    private let tracking: any TodaySleepTracking
    private var hasAttemptedInitialLoad = false
    private(set) var hasLoadedOnce = false

    private(set) var selectedSleepDay: SleepDay
    private(set) var activeSession: SleepSession?
    private(set) var sessions: [SleepSession]
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        tracking: any TodaySleepTracking,
        selectedSleepDay: SleepDay? = nil,
        sessions: [SleepSession] = [],
        activeSession: SleepSession? = nil
    ) {
        self.tracking = tracking
        self.selectedSleepDay = selectedSleepDay ?? SleepDay(containing: .now)
        self.sessions = sessions
        self.activeSession = activeSession
    }

    var isSessionActive: Bool {
        activeSession?.isActive == true
    }

    var summary: TodaySummary {
        TodaySummary(
            sessions: sessions,
            sleepDay: selectedSleepDay,
            now: .now
        )
    }

    var screenState: TodayScreenState {
        if isLoading && hasLoadedOnce == false {
            return .loading
        }

        if isLoading {
            return .partial
        }

        if sessions.isEmpty && activeSession == nil {
            return .empty
        }

        return .content
    }

    func loadIfNeeded() async {
        guard hasAttemptedInitialLoad == false else { return }
        hasAttemptedInitialLoad = true
        await load()
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let activeSession = tracking.loadActiveSession()
            async let sessions = tracking.loadSessions(for: selectedSleepDay)

            self.activeSession = try await activeSession
            self.sessions = try await sessions
            hasLoadedOnce = true
            errorMessage = nil
        } catch {
            hasLoadedOnce = true
            errorMessage = error.localizedDescription
        }
    }

    func selectSleepDay(containing date: Date) async {
        selectedSleepDay = SleepDay(containing: date)
        await load()
    }

    func toggleSession(now: Date = .now) async {
        if isSessionActive {
            await stopSession(at: now)
        } else {
            await startSession(at: now)
        }
    }

    func startSession(at startAt: Date) async {
        isLoading = true
        defer { isLoading = false }

        do {
            activeSession = try await tracking.startSession(at: startAt)
            sessions = try await tracking.loadSessions(for: selectedSleepDay)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopSession(at endAt: Date) async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await tracking.stopSession(at: endAt)
            activeSession = nil
            sessions = try await tracking.loadSessions(for: selectedSleepDay)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addManualSession(startAt: Date, endAt: Date) async throws {
        _ = try await tracking.addCompletedSession(startAt: startAt, endAt: endAt)
        await load()
    }
}

enum TodayScreenState: Equatable, Sendable {
    case loading
    case empty
    case partial
    case content
}

struct TodaySummary: Equatable, Sendable {
    let totalSleep: String
    let sessionCount: Int
    let totalAwakeTime: String

    var sessionCountLabel: String {
        "\(sessionCount)"
    }

    private init(
        totalSleep: String,
        sessionCount: Int,
        totalAwakeTime: String
    ) {
        self.totalSleep = totalSleep
        self.sessionCount = sessionCount
        self.totalAwakeTime = totalAwakeTime
    }

    init(
        sessions: [SleepSession],
        sleepDay: SleepDay,
        now: Date
    ) {
        let boundedIntervals = sessions.compactMap { $0.boundedInterval(within: sleepDay.interval, now: now) }

        let totalSleepDuration = boundedIntervals.reduce(into: TimeInterval.zero) { result, interval in
            result += interval.duration
        }
        let awakeWindowEnd = min(max(now, sleepDay.interval.start), sleepDay.interval.end)
        let elapsedDayDuration = max(awakeWindowEnd.timeIntervalSince(sleepDay.interval.start), 0)
        let totalAwakeDuration = max(elapsedDayDuration - totalSleepDuration, 0)

        self.totalSleep = Self.format(duration: totalSleepDuration)
        self.sessionCount = sessions.count
        self.totalAwakeTime = Self.format(duration: totalAwakeDuration)
    }

    private static func format(duration: TimeInterval) -> String {
        let totalMinutes = Int(duration / 60)

        if totalMinutes == 0 {
            return duration > 0 ? "<1m" : "0m"
        }

        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }

        return "\(minutes)m"
    }

    static let loadingPlaceholder = TodaySummary(
        totalSleep: "--",
        sessionCount: 0,
        totalAwakeTime: "--"
    )
}
