//
//  HomeView.swift
//  Salah
//
//  Created by Qassim on 12/9/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var locationState: LocationState
    var body: some View {
        TabView {
            VStack {
                Text("First")
                    .font(.largeTitle)
                NavigationLink(destination: ManualLocationView()) {
                    Text("Select Manual Location")
                }
            }
            VStack {
                Text("Second")
                    .font(.largeTitle)
                NavigationLink(destination: ManualLocationView()) {
                    Text("Select Manual Location")
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    NavigationLink(destination: SalahDetailView(lat: locationState.latitude, long: locationState.longitude, timeZone: +1.0)) {
                        Image(systemName: "plus.circle.fill")
                            .font(.subheadline)
                    }
                   
                    Spacer()
                    Button(action: {
                        // Action for the home button
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(LocationState())
}
