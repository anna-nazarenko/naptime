//
//  EditSessionViewModel.swift
//  Naptime
//
//  Created by Anna Nazarenko on 26/08/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class EditSessionViewModel {
    private let sessionID: UUID
    private let onSave: @Sendable (UUID, Date, Date) async throws -> Void
    private static let invalidTimeRangeMessage = "End time must be later than start time."

    var startAt: Date {
        didSet { errorMessage = nil }
    }
    var endAt: Date {
        didSet { errorMessage = nil }
    }
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    init(
        session: SleepSession,
        onSave: @escaping @Sendable (UUID, Date, Date) async throws -> Void
    ) {
        self.sessionID = session.id
        self.startAt = session.startAt
        self.endAt = session.endAt ?? .now
        self.onSave = onSave
    }

    var canSave: Bool {
        isSaving == false
    }

    func save() async -> Bool {
        guard canSave else { return false }
        guard endAt > startAt else {
            errorMessage = Self.invalidTimeRangeMessage
            return false
        }

        isSaving = true
        defer { isSaving = false }

        do {
            try await onSave(sessionID, startAt, endAt)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
