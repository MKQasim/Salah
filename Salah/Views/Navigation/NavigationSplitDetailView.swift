//
//  NavigationSplitDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI
import SwiftUI
import CoreLocation


struct NavigationSplitDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var locationState:LocationState
    @EnvironmentObject private var navigationState: NavigationState
    @State private var isPrayerDetailViewPresented = false
    @State private var searchable = ""
    @State private var isSheet = false
    @State private var isSheetSetting = false
    @State private var isDetail = false
    @State private var isLocationPermissionEnabled = false
    
    var body: some View {
        NavigationSplitView{
            List(selection: $navigationState.sidebarSelection){
                ForEach(locationState.cities){ location in
                    NavigationLink(value: NavigationItem.location(location), label: {
                        Text(location.city ?? "Nap" )
                        DetailLocationListRowCellView(isFullScreenView: $isPrayerDetailViewPresented, location: location, isCurrent: false)
                        { location in
                            print("cell taped")
                            isPrayerDetailViewPresented =  isPrayerDetailViewPresented
                            navigationState.sidebarSelection = .nocurrentLocationWithSelected(location)
                        }.id(location)
                    }).buttonStyle(GradientButtonStyle())
                        
                }
                .onDelete(perform: delete)
                   
                
                Button(action: {
                    isSheet.toggle()
                }, label: {
                    Label("Add a city",systemImage: "plus")
                })
                .frame(width: 200, height: 50, alignment: .leading)
                .buttonStyle(GradientButtonStyle())
                
                NavigationLink(value: NavigationItem.qiblaDirection, label: {
                    Text("Qibla Direction")
                }).buttonStyle(GradientButtonStyle())
                    .tag(NavigationItem.qiblaDirection)
            }
            .frame(width: 400)
            .navigationTitle("Salah")
            .toolbar{
                ToolbarItem(id: "sidebar", placement: .primaryAction){
                    Button(action: {
                        isSheetSetting.toggle()
                    }, label: {
                        Label("Open add city", systemImage: "gear")
                    }).buttonStyle(GradientButtonStyle())
                        .frame(width: 30, height: 30, alignment: .center)
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(15)
                        .shadow(color: .gray, radius: 10, x: 0, y: 10)
                }
            }
        } 
    detail:
     {
        switch navigationState.sidebarSelection {
        case .noCurrentLocationWithoutItem:
            VStack{
                Spacer()
                Button(action: {
                         
                      }) {
                          Text("Allow Current Location")
                              .padding()
                              .background(Color.blue)
                              .foregroundColor(Color.white)
                              .cornerRadius(8)
                      }
                      .buttonStyle(BorderlessButtonStyle())
                      .labelStyle(.iconOnly)
                              .symbolVariant(.fill)
                              .tint(.blue)
                              .cornerRadius(8)
                              // Show or hide the button based on the location status
                              .opacity(PermissionsManager.shared.locationPermissionEnabled == true ? 0 : 1)
                     
                Spacer()
                Text("Please add a location to view Prayers")
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Spacer()
            }
        case .currentLocation:
            PrayerDetailView(
                selectedLocation: locationState.currentLocation,
                isDetailViewPresented: $isPrayerDetailViewPresented, onDismiss: {
                    print("onDismiss")
                }
            )
            .navigationTitle("Nuremberg")
        case .location(let location):
            PrayerDetailView(
                selectedLocation: location,
                isDetailViewPresented: $isPrayerDetailViewPresented).navigationTitle(location.city ?? "")
                .id(location)
        case .nocurrentLocationWithSelected(let location):
            PrayerDetailView(
                selectedLocation: location,
                isDetailViewPresented: $isPrayerDetailViewPresented).navigationTitle(location.city ?? "")
                .id(location)
        case .qiblaDirection:
            QiblaView()
                .tag(NavigationItem.qiblaDirection)
                .tabItem {
                    Label("Qibla Direction", systemImage: "location.north")
                }
        default:
            Text("Hello")
        }
    }
        .overlay(EmptyView().sheet(isPresented: $isSheet, content: {
            NavigationStack{
                ManualLocationView(
                    searchable: $searchable,
                    isDetailView: $isDetail,
                    onDismiss: { location in
                        print($isPrayerDetailViewPresented , "onDismiss called")
                        isDetail = false
                        isSheet.toggle()
                        navigationState.sidebarSelection = .nocurrentLocationWithSelected(location)
                    }
                )
#if os(iOS)
                .searchable(text: $searchable, placement: .navigationBarDrawer(displayMode: .always),prompt: "Search for a city")
#endif
                .toolbar{
                    ToolbarItem(placement: .cancellationAction, content: {
                        Button(action: {
                            isSheet.toggle()
                        }, label: {
                            Text("Cancel")
                        })
                        .buttonStyle(GradientButtonStyle())
                    })
                }
            }
            .buttonStyle(GradientButtonStyle())
#if os(macOS)
            .frame(minWidth: 800, minHeight: 460)
#endif
        }))
        .overlay(EmptyView().sheet(isPresented: $isSheetSetting, content: {
            NavigationStack{
                SettingsView()
            }
            .buttonStyle(GradientButtonStyle())
        }))
        .onAppear{
            if navigationState.sidebarSelection == nil {
                if locationState.isLocation && locationState.cities.isEmpty {
                    navigationState.sidebarSelection = .currentLocation
                } else if !locationState.cities.isEmpty {
                    navigationState.sidebarSelection = .location(locationState.cities[0])
                } else {
                    navigationState.sidebarSelection = .noCurrentLocationWithoutItem
                }
            }
        }
    }
    func delete(at offsets: IndexSet) {
        locationState.cities.remove(atOffsets: offsets)
    }
}


#Preview {
    NavigationSplitDetailView()
}
