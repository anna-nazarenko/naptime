//
//  SwiftDataSleepSessionRecord.swift
//  Naptime
//
//  Created by Codex on 26/08/25.
//

import Foundation
import SwiftData

@Model
final class SwiftDataSleepSessionRecord {
    @Attribute(.unique) var id: UUID
    var startAt: Date
    var endAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var createdSourceRawValue: String
    var lastModifiedSourceRawValue: String

    init(
        id: UUID,
        startAt: Date,
        endAt: Date?,
        createdAt: Date,
        updatedAt: Date,
        createdSource: SleepSessionSource,
        lastModifiedSource: SleepSessionSource
    ) {
        self.id = id
        self.startAt = startAt
        self.endAt = endAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdSourceRawValue = createdSource.rawValue
        self.lastModifiedSourceRawValue = lastModifiedSource.rawValue
    }
}

extension SwiftDataSleepSessionRecord {
    var createdSource: SleepSessionSource {
        get { SleepSessionSource(rawValue: createdSourceRawValue) ?? .iphone }
        set { createdSourceRawValue = newValue.rawValue }
    }

    var lastModifiedSource: SleepSessionSource {
        get { SleepSessionSource(rawValue: lastModifiedSourceRawValue) ?? .iphone }
        set { lastModifiedSourceRawValue = newValue.rawValue }
    }

    func asDomain() throws -> SleepSession {
        try SleepSession(
            id: id,
            startAt: startAt,
            endAt: endAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            createdSource: createdSource,
            lastModifiedSource: lastModifiedSource
        )
    }
}
