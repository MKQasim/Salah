//
//  SidebarView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var locationState:LocationState
    var body: some View {
        NavigationSplitView{
            List{
                Text("Current Location")
            }
        } detail: {
            switch locationManager.locationStatus {
            case .notDetermined, .restricted, .denied:
                SalahDetailView(lat: locationState.latitude, long: locationState.longitude, timeZone: +1.0)
            case .authorizedAlways, .authorizedWhenInUse:
                SalahDetailView(lat: locationState.latitude, long: locationState.longitude, timeZone: +1.0)
                #if os(iOS)
            case .authorized:
                SalahDetailView(lat: locationState.latitude, long: locationState.longitude, timeZone: +1.0)
                #endif
            default:
                Text("Restricted Access")
            }
            
        }
    }
}

#Preview {
    SidebarView()
}
