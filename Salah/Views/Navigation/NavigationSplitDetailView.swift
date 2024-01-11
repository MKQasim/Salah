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
    @State private var isPrayerDetailViewPresented = false
    @State private var searchable = ""
    @State private var isSheet = false
    @State private var isDetail = false
    var body: some View {
        NavigationSplitView{
            List(selection: $navigationState.sidebarSelection){
                if locationManager.locationStatus == .denied && locationState.cities.count == 0 {
                        NavigationLink(value: NavigationItem.nocurrentLocation, label: {
                            Text("Location Denied")
                        })
                }
                else{
                    NavigationLink(value: NavigationItem.currentLocation, label: {
                        Text("Current Location")
                    })
                }
                ForEach(locationState.cities){ location in
                    NavigationLink(value: NavigationItem.location(location), label: {
                        Text(location.city ?? "")
                    })
                }
            }
            .navigationTitle("Salah")
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
            case .nocurrentLocation:
                VStack{
                    Text("No Location Added")
                }
            case .currentLocation:
                PrayerDetailView(
                    selectedLocation: locationState.currentLocation,
                    isDetailViewPresented: $isPrayerDetailViewPresented, onDismiss: {
                    print("onDismiss")
                    }
                )
                    .navigationTitle("Nuremberg")
                #if !os(macOS)
                    .toolbarBackground(.automatic, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                #endif
                    .background(
                        AngularGradient(colors: [.journal,.journal2], center: .bottomTrailing)
                    )
            case .location(let location):
                PrayerDetailView(selectedLocation:location, isDetailViewPresented: $isPrayerDetailViewPresented)
                    .navigationTitle(location.city ?? "")
                #if !os(macOS)
                    .toolbarBackground(.automatic, for: .navigationBar)
                    .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                #endif
                    .background(
                        AngularGradient(colors: [.journal,.journal2], center: .bottomTrailing)
                    )
            case .none:
                VStack{
                    Text("No Location Added")
                }
            case .some(.qiblaDirection):
                Text(" Location Added qiblaDirection ")
            }
        }
        .sheet(isPresented: $isSheet){
            NavigationStack{
                ManualLocationView(searchable: $searchable, isDetailView: $isDetail, onDismiss: {
                    print($isPrayerDetailViewPresented , "sheet(isPresented: $isSheet)")
                })
                    .toolbar{
                        ToolbarItem(placement: .cancellationAction, content: {
                            Button(action: {
                                isSheet.toggle()
                            }, label: {
                                Text("Cancel")
                            })
                        })
                    }
            }
            #if os(macOS)
            .frame(minWidth: 600, minHeight: 400)
            #endif
        }
        .onAppear{
            if navigationState.sidebarSelection == nil {
                if locationState.isLocation {
                    navigationState.sidebarSelection = .currentLocation
                }
                else if locationState.cities.count > 0 {
                    navigationState.sidebarSelection = .location(locationState.cities[0])
                }
                else{
                    navigationState.sidebarSelection = .nocurrentLocation
                }
            }
        }
    }
}

#Preview {
    NavigationSplitDetailView()
}
