//
//  NaptimeApp.swift
//  Naptime
//
//  Created by Anna Nazarenko on 10/3/26.
//

import SwiftData
import SwiftUI

@main
struct NaptimeApp: App {
    private let modelContainer: ModelContainer
    private let todayViewModel: TodayViewModel

    init() {
        do {
            let container = try ModelContainer(for: SwiftDataSleepSessionRecord.self)
            self.modelContainer = container
            self.todayViewModel = TodayViewModel(
                tracking: DefaultTodaySleepTracking(
                    repository: SwiftDataSleepSessionRepository(modelContainer: container)
                )
            )
        } catch {
            fatalError("Failed to configure SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(todayViewModel: todayViewModel)
        }
        .modelContainer(modelContainer)
    }
}
