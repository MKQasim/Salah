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
    @EnvironmentObject private var navigationState: NavigationState
    
    @State private var isSheet = false
    var body: some View {
        NavigationSplitView{
            List(selection: $navigationState.sidebarSelection){
                ForEach(locationState.cities){city in
                    NavigationLink(value: city, label: {
                        Text(city.city)
                    })
                }
            }
            .toolbar{
                ToolbarItem(id: "sidebar", placement: .primaryAction){
                    Button(action: {
                        isSheet.toggle()
                    }, label: {
                        Label("Open add city", systemImage: "plus")
                    })
                }
            }
        } detail: {
            switch navigationState.sidebarSelection {
            case .currentLocation:
                SalahDetailView(city: Cities(city: "Nuremberg", lat: 49.10, long: 11.01, timeZone: +1.0))
            case .city(let cities):
                Text("Hello")
//                SalahDetailView(city: cities)
            case .none:
                SalahDetailView(city: Cities(city: "Nuremberg", lat: 49.10, long: 11.01, timeZone: +1.0))
            }
        }
        .sheet(isPresented: $isSheet){
                ManualLocationView(isSheet: $isSheet)
            
        }
        
    }
}

#Preview {
    SidebarView()
}
