//
//  SalahApp.swift
//  Salah
//
//  Created by Muhammad's on 02.03.24.
//

import SwiftUI
import SwiftData

@main
struct SalahApp: App {
    
    let fileShared = FileStorageManager.shared
    @StateObject var currentTheme: Theme = Theme()
    @StateObject var viewModel: ContentViewModel = {
        // Create the schema
        let schema = Schema([
            PrayerPlace.self,
        ])
        
        // Configure the model container
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        // Create the sharedModelContainer
        let sharedModelContainer: ModelContainer
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        // Initialize and return the viewModel
        return ContentViewModel(context: sharedModelContainer.mainContext)
    }()
    
    var sharedModelContainer: ModelContainer
    
    init() {
        // Create the schema
        let schema = Schema([
            PrayerPlace.self,
        ])
        
        // Configure the model container
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        // Initialize the sharedModelContainer
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
//            ContentView()
            LocationPermissionOnboard()
                .onAppear{
                    fileShared.loadSettings(locationPermissionEnabled: nil)
                }
//
        }
        .environmentObject(currentTheme)
        .environmentObject(viewModel)
        .modelContainer(sharedModelContainer)
    }
}




