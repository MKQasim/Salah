//
//  MacView.swift
//  Salah
//
//  Created by Muhammad's on 19.03.24.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - Spacific for MAC

extension ContentView {
    var MacView: some View {
        NavigationSplitView {
            SideView()
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        AddButton()
                    }
                    
                    ToolbarItem(placement: .automatic) {
                        LocationButton()
                    }
                    
                    ToolbarItem(placement: .automatic) {
                        QiblaButton()
                    }
                   
                    ToolbarItem(placement: .automatic) {
                        SettingsButton()
                    }
                }.frame(minWidth: 260) // Set minimum width for Mac
        } detail: {
            ContainerView(viewModel: viewModel)
                .frame(minWidth: 400) // Set minimum width for Mac
        }
        .sheet(isPresented: $viewModel.isChooseCityViewPresented) {
            ChooseCityView(onDismiss: {
                print("ChooseCityView dismiss")
            })
                .environmentObject(viewModel)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
                .frame(minWidth: 400, idealWidth: 600, minHeight: 400, idealHeight: 600, alignment: .center)
        }
        .navigationSplitViewStyle(.automatic)
    }
}

struct SideView : View {
    var body: some View{
        LocationListView()
    }
}

struct ContentViewI_Previews: PreviewProvider {
    static var viewModel: ContentViewModel = {
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
    
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(Theme()) // Provide a dummy Theme
                .preferredColorScheme(.light) // Set preferred color scheme
            
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(Theme()) // Provide a dummy Theme
                .preferredColorScheme(.dark) // Set preferred color scheme
        }
    }
}
