//
//  TestSkopiaAstroDailyApp.swift
//  TestSkopiaAstroDaily
//
//  Created by Anna Karla Americo Damasco on 14/09/25.
//

import SwiftUI

@main
struct TestSkopiaAstroDailyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
