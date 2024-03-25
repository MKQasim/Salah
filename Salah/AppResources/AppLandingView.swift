//
//  AppLandingView.swift
//  Salah
//
//  Created by Qassim on 12/9/23.
//

import SwiftUI

public struct AppLandingView: View {
    
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var animationAmount = 2.0
    
    public var body: some View {
        NavigationStack{
            VStack{
                VStack{
                    Text("Start with new journey of Salah Tracking")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                    Text("We do not share your location to any third parties servers and really care for your privacy.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom,20)
                Spacer()
                Image(systemName: "paperplane.circle.fill")
                    .foregroundColor(.blue)
                    .font(.largeTitle)
                    .scaleEffect(animationAmount)
                    .animation(
                        .easeInOut(duration: 3),
                        value: animationAmount
                    )
                    .padding(.bottom,20)
                Spacer()
                switch viewModel.permissionManager.locationManager?.locationStatus {
                case .denied:
                    EmptyView()
                case .authorizedAlways, .authorizedWhenInUse:
                    Button(action: locationCheck, label: {
                        Text("Get current location")
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.bottom,8)
                    #if !os(watchOS)
                case .authorized:
                    Button(action: locationCheck, label: {
                        Text("Get current location")
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.bottom,8)
                    #endif
                default:
                    Button(action: {
                        viewModel.permissionManager.locationManager?.requestLocation()
                    }, label: {
                        Text("Allow location permission")
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.bottom,8)
                }
            }
            .padding()
        }
        .onAppear{
            animationAmount += 2
        }
    }
    
    func locationCheck() {
        switch viewModel.permissionManager.locationManager?.locationStatus {
        case .notDetermined, .restricted, .denied:
            viewModel.isLocation = true
        case .authorizedAlways, .authorizedWhenInUse:
            viewModel.permissionManager.locationManager?.requestLocation()
            
            viewModel.isLocation = true
            #if !os(watchOS)
        case .authorized:
            viewModel.permissionManager.locationManager?.requestLocation()
            
            viewModel.isLocation = true
            #endif
        default:
            viewModel.isLocation = true
        }
    }
}

#Preview {
    AppLandingView()
}
