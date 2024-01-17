//
//  NavigationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI
import CoreLocation

struct MainNavigationView: View {
    @EnvironmentObject private var locationState: LocationState
    @Environment (\.horizontalSizeClass) private var horizontalSize
    
    var body: some View {
        Group{
            switch horizontalSize{
            case .compact:
                NavigationStack{
                    TabbarView()
#if !os(macOS)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
#endif
                        .background(
                            AngularGradient(colors: [.journal,.journal2], center: .bottomTrailing)
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
    
    
}

#Preview {
    MainNavigationView()
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
}
