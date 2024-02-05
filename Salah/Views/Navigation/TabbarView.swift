//
//  TabbarView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct TabbarView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject var locationState: LocationState
    @State private var isSheet = false
    @State private var isShowingQibla = false // Add state to track if QiblaView is shown
    @State private var isPrayerDetailViewPresented = false
    @Environment(\.dismissSearch) private var dismissSearchAction

    var body: some View {
        TabView(selection: $navigationState.tabbarSelection) {
            // Add QiblaView as the first tab
//            QiblaView()
//                .tag(NavigationItem.qiblaDirection)
//                .tabItem {
//                    Label("Qibla Direction", systemImage: "location.north")
//                }

            // Other tabs go here
            if locationManager.locationStatus == .denied {
                if locationState.cities.count == 0 {
                    VStack {
                        Text("Add Location to View screen")
                            .foregroundStyle(.gray)
                    }
                    .tag(NavigationItem.nocurrentLocation)
                }
            } else if locationState.isLocation == false {
                if locationState.cities.count == 0 {
                    VStack {
                        Text("Add Location to View screen")
                            .foregroundStyle(.gray)
                    }
                    .tag(NavigationItem.nocurrentLocation)
                }
            } else {
                if locationState.isLocation {
                    PrayerDetailView(
                        selectedLocation: locationState.currentLocation,
                        isDetailViewPresented: $isPrayerDetailViewPresented, onDismiss: {
                        print("onDismiss")
                        }
                    )
                    .navigationTitle(locationState.currentLocation?.city ?? "Nuremberg")
                    .tag(NavigationItem.currentLocation)
                    .tabItem {
                        Label("Current Location", systemImage: "location.fill")
                    }
                }
}
            ForEach(locationState.cities, id: \.self) { location in
                VStack {
                    PrayerDetailView(
                        selectedLocation: location,
                        isDetailViewPresented: $isPrayerDetailViewPresented, onDismiss: {
                        print("onDismiss")
                        }
                    )
                }
                .navigationTitle(location.city ?? "")
                .tag(NavigationItem.location(location))
            }
        }
        .onChange(of: navigationState.tabbarSelection) { newSelection in
            if newSelection == NavigationItem.qiblaDirection {
                isShowingQibla = true
            }
        }
        #if !os(macOS) && !os(watchOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .fullScreenCover(isPresented: $isSheet) {
            NavigationStack {
                LocationDetailView(isFullScreenView: $isSheet)
            }
        }
        #endif
        .toolbar {
            #if !os(macOS)
            ToolbarItemGroup(placement: .bottomBar) {
                // Add button to show/hide QiblaView
//                Button(action: {
//                    isShowingQibla.toggle()
//                    if isShowingQibla {
//                        navigationState.tabbarSelection = NavigationItem.qiblaDirection
//                    } else {
//                        navigationState.tabbarSelection = NavigationItem.currentLocation
//                    }
//                }) {
//                    Image(systemName: "location.north")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }
                Spacer()
                Button(action: {
                    isSheet.toggle()
                }) {
                    Image(systemName: "list.bullet")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
               
            }
            #endif
        }
    }
}



#if os(iOS)
struct CustomPageControl: UIViewRepresentable {
    
    let numberOfPages: Int
    @Binding var currentPage: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let view = UIPageControl()
        view.numberOfPages = numberOfPages
        view.backgroundStyle = .prominent
        view.addTarget(context.coordinator, action: #selector(Coordinator.pageChanged), for: .valueChanged)
        return view
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = currentPage
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CustomPageControl
        
        init(_ parent: CustomPageControl) {
            self.parent = parent
        }
        
        @objc func pageChanged(sender: UIPageControl) {
            parent.currentPage = sender.currentPage
        }
    }
}
#endif

#Preview {
    TabbarView()
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
        .environmentObject(NavigationState())
}
