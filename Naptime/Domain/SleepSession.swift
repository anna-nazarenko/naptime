//
//  SleepSession.swift
//  Naptime
//
//  Created by Anna Nazarenko on 17/3/26.
//

import Foundation

struct SleepSession: Identifiable, Equatable, Hashable, Codable, Sendable {
    let id: UUID

    var startAt: Date
    var endAt: Date?

    let createdAt: Date
    var updatedAt: Date

    let createdSource: SleepSessionSource
    var lastModifiedSource: SleepSessionSource

    init(
        id: UUID = UUID(),
        startAt: Date,
        endAt: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        createdSource: SleepSessionSource,
        lastModifiedSource: SleepSessionSource? = nil
    ) throws {
        if let endAt, endAt <= startAt {
            throw SleepSessionError.invalidTimeRange
        }

        self.id = id
        self.startAt = startAt
        self.endAt = endAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdSource = createdSource
        self.lastModifiedSource = lastModifiedSource ?? createdSource
    }

    var isActive: Bool {
        endAt == nil
    }

    var isCompleted: Bool {
        endAt != nil
    }

    var duration: TimeInterval? {
        guard let endAt else { return nil }
        return endAt.timeIntervalSince(startAt)
    }

    func overlaps(with interval: DateInterval) -> Bool {
        let sessionEnd = endAt ?? .distantFuture
        return startAt < interval.end && sessionEnd > interval.start
    }

    func boundedInterval(within interval: DateInterval, now: Date = .now) -> DateInterval? {
        let boundedStart = max(startAt, interval.start)
        let boundedEnd = min(endAt ?? now, interval.end)

        guard boundedEnd > boundedStart else {
            return nil
        }

        return DateInterval(start: boundedStart, end: boundedEnd)
    }

    func sleepDuration(within interval: DateInterval, now: Date = .now) -> TimeInterval {
        boundedInterval(within: interval, now: now)?.duration ?? 0
    }

    mutating func finish(
        at endAt: Date,
        source: SleepSessionSource,
        now: Date = .now
    ) throws {
        guard isActive else {
            throw SleepSessionError.sessionAlreadyCompleted
        }

        guard endAt > startAt else {
            throw SleepSessionError.invalidTimeRange
        }

        self.endAt = endAt
        self.updatedAt = now
        self.lastModifiedSource = source
    }

    mutating func updateTimes(
        startAt: Date,
        endAt: Date?,
        source: SleepSessionSource,
        now: Date = .now
    ) throws {
        if let endAt, endAt <= startAt {
            throw SleepSessionError.invalidTimeRange
        }

        self.startAt = startAt
        self.endAt = endAt
        self.updatedAt = now
        self.lastModifiedSource = source
    }
}

enum SleepSessionSource: String, CaseIterable, Codable, Sendable {
    case iphone
    case appleWatch
    case manual
    case system
}

enum SleepSessionError: LocalizedError, Equatable, Sendable {
    case invalidTimeRange
    case sessionAlreadyCompleted
    case activeSessionAlreadyExists
    case noActiveSession
    case overlappingSession

    var errorDescription: String? {
        switch self {
        case .invalidTimeRange:
            return "End time must be later than start time."
        case .sessionAlreadyCompleted:
            return "This sleep session is already completed."
        case .activeSessionAlreadyExists:
            return "Another active sleep session already exists."
        case .noActiveSession:
            return "There is no active sleep session."
        case .overlappingSession:
            return "Sleep sessions cannot overlap."
        }
    }
}
