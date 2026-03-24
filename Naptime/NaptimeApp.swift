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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SwiftDataSleepSessionRecord.self)
    }
}
