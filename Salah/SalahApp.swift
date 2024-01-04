//
//  SalahApp.swift
//  Salah
//
//  Created by Qassim on 12/6/23.
//

import SwiftUI

@main
struct SalahApp: App {
    let fileShared = FileStorageManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear{
                    fileShared.loadSettings()
                }
        }
    }
}
