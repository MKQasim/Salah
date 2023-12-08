//
//  NavigationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct MainNavigationView: View {

    @EnvironmentObject private var locationState: LocationState
    @Environment (\.horizontalSizeClass) private var horizontalSize
    
    var body: some View {
        switch horizontalSize{
        case .compact:
            NavigationStack{
                SalahDetailView(lat: locationState.latitude, long: locationState.longitude, timeZone: +1.0)
            }
        case .regular:
            SidebarView()
        case .none:
            SidebarView()
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
