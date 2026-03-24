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

    private(set) var activeSession: SleepSession?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        tracking: any TodaySleepTracking,
        activeSession: SleepSession? = nil
    ) {
        self.tracking = tracking
        self.activeSession = activeSession
    }

    var isSessionActive: Bool {
        activeSession?.isActive == true
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            activeSession = try await tracking.loadActiveSession()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
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
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
