//
//  NavigationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct MainNavigationView: View {
    
    @Environment (\.horizontalSizeClass) private var horizontalSize
    
    var body: some View {
        switch horizontalSize{
        case .compact:
            NavigationStack{
                TabbarView()
                #if !os(macOS)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                    .toolbarBackground(.visible, for: .bottomBar)
                    .toolbarBackground(.ultraThinMaterial, for: .bottomBar)
                #endif
                    .background(
                        AngularGradient(colors: [.sunset,.sunset2], center: .bottomTrailing)
                    )
                    
            }
        case .regular:
            NavigationSplitDetailView()
        case .none:
            NavigationSplitDetailView()
        default:
            Text("Regular")
        }
    }
}

#Preview {
    MainNavigationView()
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
}
