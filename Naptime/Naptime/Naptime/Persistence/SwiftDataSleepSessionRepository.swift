//
//  SwiftDataSleepSessionRepository.swift
//  Naptime
//
//  Created by Codex on 26/08/25.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataSleepSessionRepository: SleepSessionRepository, @unchecked Sendable {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func createSession(
        startAt: Date,
        createdSource: SleepSessionSource
    ) async throws -> SleepSession {
        let context = ModelContext(modelContainer)

        guard try fetchActiveRecord(in: context) == nil else {
            throw SleepSessionError.activeSessionAlreadyExists
        }

        let now = Date.now
        let session = try SleepSession(
            startAt: startAt,
            createdAt: now,
            updatedAt: now,
            createdSource: createdSource
        )
        let record = SwiftDataSleepSessionRecord(
            id: session.id,
            startAt: session.startAt,
            endAt: session.endAt,
            createdAt: session.createdAt,
            updatedAt: session.updatedAt,
            createdSource: session.createdSource,
            lastModifiedSource: session.lastModifiedSource
        )

        context.insert(record)
        try context.save()

        return try record.asDomain()
    }

    func finishActiveSession(
        endAt: Date,
        source: SleepSessionSource
    ) async throws -> SleepSession {
        let context = ModelContext(modelContainer)

        guard let record = try fetchActiveRecord(in: context) else {
            throw SleepSessionError.noActiveSession
        }

        var session = try record.asDomain()
        try session.finish(at: endAt, source: source)

        record.endAt = session.endAt
        record.updatedAt = session.updatedAt
        record.lastModifiedSource = session.lastModifiedSource

        try context.save()

        return session
    }

    func fetchActiveSession() async throws -> SleepSession? {
        let context = ModelContext(modelContainer)
        return try fetchActiveRecord(in: context)?.asDomain()
    }

    func fetchSessions(for sleepDay: SleepDay) async throws -> [SleepSession] {
        let context = ModelContext(modelContainer)
        let interval = sleepDay.interval

        let descriptor = FetchDescriptor<SwiftDataSleepSessionRecord>(
            predicate: #Predicate { record in
                record.startAt < interval.end
            },
            sortBy: [SortDescriptor(\.startAt, order: .reverse)]
        )

        let records = try context.fetch(descriptor)
        return try records
            .map { try $0.asDomain() }
            .filter { $0.overlaps(with: interval) }
    }

    private func fetchActiveRecord(in context: ModelContext) throws -> SwiftDataSleepSessionRecord? {
        var descriptor = FetchDescriptor<SwiftDataSleepSessionRecord>(
            predicate: #Predicate { record in
                record.endAt == nil
            },
            sortBy: [SortDescriptor(\.startAt, order: .reverse)]
        )
        descriptor.fetchLimit = 2

        let records = try context.fetch(descriptor)

        if records.count > 1 {
            throw SleepSessionError.activeSessionAlreadyExists
        }

        return records.first
    }
}
