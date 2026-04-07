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
    private let onDelete: @Sendable (UUID) async throws -> Void
    private static let invalidTimeRangeMessage = "End time must be later than start time."

    var startAt: Date {
        didSet { errorMessage = nil }
    }
    var endAt: Date {
        didSet { errorMessage = nil }
    }
    private(set) var isSaving = false
    private(set) var isDeleting = false
    private(set) var errorMessage: String?

    init(
        session: SleepSession,
        onSave: @escaping @Sendable (UUID, Date, Date) async throws -> Void,
        onDelete: @escaping @Sendable (UUID) async throws -> Void
    ) {
        self.sessionID = session.id
        self.startAt = session.startAt
        self.endAt = session.endAt ?? .now
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var canSave: Bool {
        isSaving == false && isDeleting == false
    }

    var canDelete: Bool {
        isSaving == false && isDeleting == false
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

    func deleteSession() async -> Bool {
        guard canDelete else { return false }

        isDeleting = true
        errorMessage = nil
        defer { isDeleting = false }

        do {
            try await onDelete(sessionID)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
