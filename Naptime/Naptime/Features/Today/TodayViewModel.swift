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
    private var hasLoaded = false

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

    func loadIfNeeded() async {
        guard hasLoaded == false else { return }
        hasLoaded = true
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
            errorMessage = nil
        } catch {
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
}
