//
//  NavigationSplitDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct NavigationSplitDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var locationState:LocationState
    @EnvironmentObject private var navigationState: NavigationState
    
    @State private var isSheet = false
    var body: some View {
        NavigationSplitView{
            List(selection: $navigationState.sidebarSelection){
                NavigationLink(value: NavigationItem.currentLocation, label: {
                    Text("Current Location")
                })
                ForEach(locationState.cities){city in
                    NavigationLink(value: NavigationItem.city(city), label: {
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
                
                PrayerDetailView(city: Cities(city: "Nuremberg", lat: 49.10, long: 11.01, timeZone: +1.0))
                    .navigationTitle("Nuremberg")
                #if !os(macOS)
                    .toolbarBackground(.automatic, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                #endif
                    .background(
                        AngularGradient(colors: [.sunset,.sunset2], center: .bottomTrailing)
                    )
            case .city(let cities):
                    PrayerDetailView(city: cities)
                    .navigationTitle(cities.city)
                #if !os(macOS)
                    .toolbarBackground(.automatic, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                #endif
                    .background(
                        AngularGradient(colors: [.sunset,.sunset2], center: .bottomTrailing)
                    )
            case .none:
                PrayerDetailView(city: Cities(city: "Nuremberg", lat: 49.10, long: 11.01, timeZone: +1.0))
                    .navigationTitle("Nuremberg")
                #if !os(macOS)
                    .toolbarBackground(.automatic, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                #endif
                    .background(
                        AngularGradient(colors: [.sunset,.sunset2], center: .bottomTrailing)
                    )
            }
        }
        .sheet(isPresented: $isSheet){
                ManualLocationView(isSheet: $isSheet)
            
        }
        
    }
}

#Preview {
    NavigationSplitDetailView()
}
