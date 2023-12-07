//
//  LocationPermissionOnboard.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI
import CoreLocationUI

struct LocationPermissionOnboard: View {
    @EnvironmentObject private var locationManager: LocationManager
    
    @State private var animationAmount = 1.0
    
    var body: some View {
        NavigationView{
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
                    .animation(
                        .easeInOut(duration: 3),
                        value: animationAmount
                    )
                    .scaleEffect(animationAmount)
                    .padding(.bottom,20)
                Spacer()
                LocationButton(action: {
                    locationManager.requestLocation()
                })
                .symbolVariant(.fill)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.bottom,8)

                Button(action: {}, label: {
                    Text("Don't want to share")
                })
                .padding(.bottom,8)
            }
            .padding()
        }
        .onAppear{
            animationAmount += 4
        }
    }
}

#Preview {
    LocationPermissionOnboard()
}
