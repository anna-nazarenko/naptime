//
//  SleepSessionRepository.swift
//  Naptime
//
//  Created by Codex on 26/08/25.
//

import Foundation

/// Persistence boundary for the first real Start / Stop flow.
/// This stays intentionally narrow so the SwiftData implementation can focus on
/// the single active-session invariant without taking on edit/list/query use cases.
protocol SleepSessionRepository: Sendable {
    func createSession(
        startAt: Date,
        createdSource: SleepSessionSource
    ) async throws -> SleepSession

    func finishActiveSession(
        endAt: Date,
        source: SleepSessionSource
    ) async throws -> SleepSession

    func fetchActiveSession() async throws -> SleepSession?
}
