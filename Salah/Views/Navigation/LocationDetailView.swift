//
//  LocationDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 18/12/2023.
//

import SwiftUI

struct LocationDetailView: View {
    @Environment (\.isSearching) var isSearching
    @EnvironmentObject private var locationState: LocationState
    @State private var isSheet = false
    @State private var searchableText = ""
    
    var body: some View {
        List{
            VStack{
                Text(locationState.defaultCityName)
            }
            ForEach(locationState.cities,id: \.self){city in
                Text("Cities")
            }
        }
        .navigationTitle("Cities")
        .searchable(text: $searchableText)
    }
}

#Preview {
    
    LocationDetailView()
        .environmentObject(LocationState())
}
