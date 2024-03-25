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







