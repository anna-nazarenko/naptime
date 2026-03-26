//
//  SleepDay.swift
//  Naptime
//
//  Created by Codex on 26/08/25.
//

import Foundation

struct SleepDay: Equatable, Hashable, Sendable {
    let interval: DateInterval

    init(interval: DateInterval) {
        self.interval = interval
    }

    init(containing date: Date, calendar: Calendar = .current) {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        self.interval = DateInterval(start: start, end: end)
    }
}
