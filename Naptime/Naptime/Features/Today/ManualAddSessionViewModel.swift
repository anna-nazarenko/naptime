//
//  ManualAddSessionViewModel.swift
//  Naptime
//
//  Created by Anna Nazarenko on 26/08/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class ManualAddSessionViewModel {
    private let onSave: @Sendable (Date, Date) async throws -> Void

    var startAt: Date
    var endAt: Date
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    init(
        startAt: Date = Calendar.current.date(byAdding: .minute, value: -30, to: .now) ?? .now,
        endAt: Date = .now,
        onSave: @escaping @Sendable (Date, Date) async throws -> Void
    ) {
        self.startAt = startAt
        self.endAt = endAt
        self.onSave = onSave
    }

    var canSave: Bool {
        isSaving == false && endAt > startAt
    }

    func save() async -> Bool {
        guard canSave else { return false }

        isSaving = true
        defer { isSaving = false }

        do {
            try await onSave(startAt, endAt)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
