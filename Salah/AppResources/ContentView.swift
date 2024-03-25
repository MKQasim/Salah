//
//  ContentView.swift
//  Salah
//
//  Created by Muhammad's on 02.03.24.
//

import SwiftUI
import SwiftData


// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @EnvironmentObject var theme: Theme
    @State var selection = 0
    var body: some View {
        ZStack {
#if os(iOS)
            let isiPhone = UIDevice.current.userInterfaceIdiom == .phone
            if isiPhone {
                iPhoneView
            } else {
                iPadView
            }

#elseif os(macOS)
            MacView
#elseif os(watchOS)
            WatchView
#elseif os(tvOS)
            TvView
#endif
        }
        .onAppear {
            if let manager = viewModel.permissionManager.locationManager{
                manager.startLocationUpdates()
                manager.checkLocationPermission { result in
                    switch result {
                    case .success(let (isEnabled, prayerPlace)):
                        viewModel.updateLocations(with: prayerPlace)
                        manager.stopLocationUpdates()
                    case .failure(let error):
                      
                        print("Failed to get location details: \(error.localizedDescription)")
                    }
                }
            }
            
//           
//            viewModel.objectWillChange.sink { value in
////                print(value)
//            }
            
            
            //------------------------ User Interface -------------------------

//
//            getTimes (date, coordinates [, timeZone [, dst [, timeFormat]]])
//
//            setMethod (method)       // set calculation method
//            adjust (parameters)      // adjust calculation parameters
//            tune (offsets)           // tune times by given offsets
//
//            getMethod ()             // get calculation method
//            getSetting ()            // get current calculation parameters
//            getOffsets ()            // get current time offsets
//

            //------------------------- Sample Usage --------------------------

//            let latitude: Double = 49.460983
//            let longitude: Double = 11.061859
//
//            // Get the current timezone
//            let timeZone = Double(TimeZone.current.secondsFromGMT()) / 3600.0
//
//            // Print the obtained values
//            print("Latitude: \(latitude), Longitude: \(longitude)")
//            print("Time Zone: \(timeZone)")


            print("on Appear")
        }
    }
}

// MARK: - Specific WatchView, TvView
extension ContentView {
    private var WatchView: some View {
        Text("Watch View")
    }
    
    private var TvView: some View {
        Text("TV View")
    }
}

// MARK: - Specific UIDevice
#if os(iOS)
extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
#endif

//struct ContentView_Previews: PreviewProvider {
//    static var viewModel: ContentViewModel = {
//        // Create the schema
//        let schema = Schema([
//            PrayerPlace.self,
//        ])
//        
//        // Configure the model container
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//        
//        // Create the sharedModelContainer
//        let sharedModelContainer: ModelContainer
//        do {
//            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//        
//        // Initialize and return the viewModel
//        return ContentViewModel(context: sharedModelContainer.mainContext)
//    }()
//    
//    static var previews: some View {
//        Group {
//            ContentView()
//                .environmentObject(viewModel)
//                .environmentObject(Theme()) // Provide a dummy Theme
//                .preferredColorScheme(.light) // Set preferred color scheme
//            
//            ContentView()
//                .environmentObject(viewModel)
//                .environmentObject(Theme()) // Provide a dummy Theme
//                .preferredColorScheme(.dark) // Set preferred color scheme
//        }
//    }
//}









// MARK: - Specific iPhoneView
//extension ContentView {
//    private var iPhoneView: some View {
//        HStack {
//            Spacer()
//            TabView(selection: $viewModel.selectedTab) {
//                NavigationView {
//                    
////                    let locationManager = LocationManager() // Replace with your actual LocationManager initialization
////                    let notificationManager = NotificationManager.shared // Replace with your actual NotificationManager initialization
////                    let fileStorageManager = FileStorageManager() // Replace with your actual FileStorageManager initialization
////                    let settingsService = SettingsRepository(fileStorageManager: fileStorageManager)
////                    
////                    let mockPermissionsManager = PermissionsManager(
////                        locationManager: locationManager,
////                        notificationManager: notificationManager,
////                        settingsService: settingsService
////                    )
////                    
////                    
////                    SettingsView(permissionsManager: mockPermissionsManager)
////                        .preferredColorScheme(.light)
//                    LocationPages()
////                        .environmentObject(viewModel)
////                        .navigationBarTitle("Location Pages")
//                        .navigationBarItems(
//                            leading:
//                                NavigationLink(destination: {
////                                    SettingsView(permissionsManager: mockPermissionsManager, isActive: $showSettings)
////                                        .preferredColorScheme(.light)
//                                }, label: {
//                                    Image(systemName: "gearshape.fill")
//                                })
//                        )
//                }
//                .tabItem {
//                    Label("Location Pages", systemImage: "square.grid.2x2")
//                }
////                .tag(Tab.locationPages)
//            }
//        }
//    }
//}
//


//// MARK: - Specific iPadView
//extension ContentView {
//    private var iPadView: some View {
//        NavigationsSplitView
//    }
//}

//// MARK: - Specific MacView
//extension ContentView {
//    private var MacView: some View {
//        NavigationsSplitView
//    }
//}

//// MARK: - Specific LocationList
//extension ContentView {
//    private var locationList: some View {
//        LocationListView()
////            .environmentObject(viewModel)
////            .navigationTitle("Locations List")
//    }
//}

// MARK: - Specific Views for each Tab
//extension ContentView {
//    private var NavigationsSplitView: some View {
//        NavigationSplitView {
//            LocationListView()
////                .environmentObject(viewModel)
//        } detail: {
//            LocationPages()
////                .environmentObject(viewModel)
//        }
//    }
//}


struct LocationPages {
    @EnvironmentObject private var viewModel: ContentViewModel
    var body : some View {
        return Text("LocationPages")
    }
}

//struct LocationListView {
//    @EnvironmentObject private var viewModel: ContentViewModel
//    var body : some View {
//        return Text("LocationListView")
//    }
//}








