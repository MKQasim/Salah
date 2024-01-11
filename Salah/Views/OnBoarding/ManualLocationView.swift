//
//  ManualLocationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import SwiftUI
import CoreLocation

struct ManualLocationView: View {
    @State private var isPrayerDetailViewPresented = false // New state to manage presentation
    @Environment(\.dismissSearch) private var dismissSearchAction
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var locationState: LocationState
    @EnvironmentObject private var navigationState: NavigationState
    @Binding var searchable: String
    @Binding var isDetailView: Bool
    var onDismiss: (() -> Void)
    @State private var countryName = ""
    @State private var cityName = ""
    @State var dropDownList: [Location] = []
    @State private var selectedLocation: Location? = nil
    @State private var isAddCitySheet = false
    @State private var isAddCitySelected = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dropDownList.filter({ searchable.isEmpty ? true : $0.city!.localizedStandardContains(searchable) }), id: \.self.id) { item in
                    NavigationLink(
                        destination: PrayerDetailViewPreview(
                            selectedLocation: item,
                            isDetailViewPresented: $isPrayerDetailViewPresented, onDismiss: {
                            onDismiss()
                            }
                        ),
                        label: {
                            Text(item.city ?? "emp")
                        }
                    )
                }
            }
            .listStyle(.plain)
            .onAppear {
                parseLocalJSONtoFetchLocations()
            }
            #if os(iOS)
            .navigationBarTitle("Locations", displayMode: .automatic)
            #endif
        }
    }
    
    func parseLocalJSONtoFetchLocations() {
        if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                let jsonData = try Data(contentsOf: fileUrl)
                let location = try? JSONDecoder().decode([Location].self, from: jsonData)
                dropDownList = location ?? []
            } catch {
                print("Error parsing JSON: \(error)")
            }
        } else {
            print("File not found")
        }
    }
}



#Preview {
    @State var isSheet = false
    @State var isDetailView = true
    
    @State var searching = ""
    return ManualLocationView(searchable: $searching, isDetailView: $isDetailView, onDismiss: {})
        .environmentObject(LocationState())
}
