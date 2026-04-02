//
//  SleepSessionRepository.swift
//  Naptime
//
//  Created by Codex on 26/08/25.
//

import Foundation

/// Persistence boundary for the first real Start / Stop flow plus the Today
/// session list read path for a selected sleep day.
protocol SleepSessionRepository: Sendable {
    func createSession(
        startAt: Date,
        createdSource: SleepSessionSource
    ) async throws -> SleepSession

    func createCompletedSession(
        startAt: Date,
        endAt: Date,
        createdSource: SleepSessionSource
    ) async throws -> SleepSession

    func updateSession(
        id: UUID,
        startAt: Date,
        endAt: Date,
        source: SleepSessionSource
    ) async throws -> SleepSession

    func finishActiveSession(
        endAt: Date,
        source: SleepSessionSource
    ) async throws -> SleepSession

    func fetchActiveSession() async throws -> SleepSession?
    func fetchSessions(for sleepDay: SleepDay) async throws -> [SleepSession]
}
