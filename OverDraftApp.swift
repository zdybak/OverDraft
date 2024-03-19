//
//  OverDraftApp.swift
//  OverDraft
//
//  Created by sawcleaver on 8/13/21.
//

import SwiftUI

@main
struct OverDraftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
