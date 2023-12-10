//
//  TabbarView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct TabbarView: View {
    
    @EnvironmentObject var locationState: LocationState
    @State private var isSheet = false
    
    var body: some View {
        TabView {
            if locationState.isLocation {
                SalahDetailView(city: Cities(city: "Nuremberg", lat: 43.33, long: 19.23, timeZone: 1.0))
            }
            ForEach(locationState.cities, id: \.self){location in
                VStack{
                    SalahDetailView(city: location)
                }
                .tag(location)
            }
//            SalahDetailView(lat: locationState.latitude, long: locationState.longitude, timeZone: +1.0)
            VStack {
                Text("Second")
                    .font(.largeTitle)
                NavigationLink(destination: ManualLocationView(isSheet: $isSheet)) {
                    Text("Add More Location")
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
//                    NavigationLink(destination: SalahDetailView(lat: locationState.latitude, long: locationState.longitude, timeZone: +1.0)) {
//                        Image(systemName: "plus.circle.fill")
//                            .font(.subheadline)
//                    }
                   
                    Spacer()
                    Button(action: {
                        // Action for the home button
                        isSheet.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.subheadline)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isSheet, content: {
            ManualLocationView(isSheet: $isSheet)
        })
//        .sheet(isPresented: $isSheet, content: {
//            ManualLocationView(isSheet: $isSheet)
//        })
    }
}

#Preview {
    TabbarView()
}
