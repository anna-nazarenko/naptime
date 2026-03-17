//
//  Naptime_Watch_App.swift
//  Naptime Watch App
//
//  Created by Anna Nazarenko on 17/3/26.
//

import AppIntents

struct Naptime_Watch_App: AppIntent {
    static var title: LocalizedStringResource { "Naptime Watch App" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
