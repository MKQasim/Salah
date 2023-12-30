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
    @State private var countdownValue1: String = "00:00:00"
    init() {
        #if os(iOS)
        let pageControl = UIPageControl()
        pageControl.frame = CGRectMake(100, 100, .infinity, 100);
        #endif
    }
    
    var body: some View {
        TabView(selection: $navigationState.tabbarSelection) {
            if locationManager.locationStatus == .denied {
                if locationState.cities.count == 0 {
                    VStack{
                        Text("Add Location to View screen")
                            .foregroundStyle(.gray)
                        Text("Countdown View 1: \(countdownValue1)")
                            .foregroundStyle(.gray)
                    }
                    .tag(NavigationItem.nocurrentLocation)
                }
            } else if locationState.isLocation == false {
                if locationState.cities.count == 0 {
                    VStack{
                        Text("Add Location to View screen")
                            .foregroundStyle(.gray)
                        Text("Countdown View 1: \(countdownValue1)")
                            .foregroundStyle(.gray)
                    }
                    .tag(NavigationItem.nocurrentLocation)
                }
            }
            else{
//                if locationState.isLocation {
//                    PrayerDetailView(selectedLocation: $locationState.currentLocation ?? Binding<Location()>)
//                        .navigationTitle(locationState.currentLocation?.city ?? "Nuremberg")
//                        .tag(NavigationItem.currentLocation)
//                        .tabItem {
//                            Label("Current Location", systemImage: "location.fill")
//                        }
//                }
            }
            ForEach(locationState.cities, id: \.self){location in
                VStack{
                    PrayerDetailView(selectedLocation: location)
                }
                .navigationTitle(location.city ?? "")
                .tag(NavigationItem.location(location))
            }
        }
        #if !os(macOS) && !os(watchOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .fullScreenCover(isPresented: $isSheet, content: {
            NavigationStack{
                LocationDetailView(isFullScreenView: $isSheet)
            }
        })
        #endif
        .toolbar {
            #if !os(macOS)
            ToolbarItemGroup(placement: .bottomBar){
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
        .onAppear {
            
        }
//        .overlay(alignment: .bottom){
//            HStack{
//                #if os(iOS)
//                Spacer()
////                CustomPageControl(numberOfPages: locationState.cities.count + 1, currentPage: $navigationState.tabbarSelection)
//                #endif
//                Spacer()
//                Button(action: {
//                    isSheet.toggle()
//                }) {
//                    Image(systemName: "list.bullet")
//                        .font(.title2)
//                }
//                .padding()
//            }
//            .background(.thinMaterial)
//            .frame(minHeight: 50)
//
//        }
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
