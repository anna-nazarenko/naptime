//
//  TodaySleepTracking.swift
//  Naptime
//
//  Created by Codex on 26/08/25.
//

import Foundation

/// Today-specific contract for the first vertical slice on iPhone.
/// The service hides persistence details and keeps the screen focused on the
/// running session state plus the selected sleep day session list.
protocol TodaySleepTracking: Sendable {
    func loadActiveSession() async throws -> SleepSession?
    func loadSessions(for sleepDay: SleepDay) async throws -> [SleepSession]
    func addCompletedSession(startAt: Date, endAt: Date) async throws -> SleepSession
    func startSession(at startAt: Date) async throws -> SleepSession
    func stopSession(at endAt: Date) async throws -> SleepSession
}

struct DefaultTodaySleepTracking: TodaySleepTracking {
    private let repository: any SleepSessionRepository

    init(repository: any SleepSessionRepository) {
        self.repository = repository
    }

    func loadActiveSession() async throws -> SleepSession? {
        try await repository.fetchActiveSession()
    }

    func loadSessions(for sleepDay: SleepDay) async throws -> [SleepSession] {
        try await repository.fetchSessions(for: sleepDay)
    }

    func addCompletedSession(startAt: Date, endAt: Date) async throws -> SleepSession {
        try await repository.createCompletedSession(
            startAt: startAt,
            endAt: endAt,
            createdSource: .manual
        )
    }

    func startSession(at startAt: Date) async throws -> SleepSession {
        do {
            return try await repository.createSession(
                startAt: startAt,
                createdSource: .iphone
            )
        } catch let error as SleepSessionError {
            guard error == .activeSessionAlreadyExists else {
                throw error
            }

            guard let activeSession = try await repository.fetchActiveSession() else {
                throw error
            }

            return activeSession
        }
    }

    func stopSession(at endAt: Date) async throws -> SleepSession {
        try await repository.finishActiveSession(
            endAt: endAt,
            source: .iphone
        )
    }
}
