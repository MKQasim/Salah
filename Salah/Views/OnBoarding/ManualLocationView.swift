//
//  ManualLocationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import SwiftUI
import CoreLocation


struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        TextField("Search for a city", text: $text)
            .padding(8)
            .background(Color(.gray))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}

struct ManualLocationView: View {
    @State private var isPrayerDetailViewPresented = false
    @Binding var searchable: String
    @Binding var isDetailView: Bool
    var onDismiss: (() -> Void)
    @State private var dropDownList: [Location] = []

    var body: some View {
        NavigationView {
            VStack {
              
                List {
#if os(macOS)
                    Section {
                      
                        SearchBar(text: $searchable)
                      
                    }
#endif
                    Section {
                        ForEach(dropDownList.filter { item in
                            searchable.isEmpty ? true : item.city?.localizedStandardContains(searchable) ?? false
                        }, id: \.self.id) { item in
                            NavigationLink(
                                destination: PrayerDetailViewPreview(
                                    selectedLocation: item,
                                    isDetailViewPresented: $isPrayerDetailViewPresented,
                                    onDismiss: {
                                        onDismiss()
                                    }
                                ),
                                label: {
                                    Text(item.city ?? "emp")
                                }
                            )
                        }
                    }
                }
                .listStyle(.plain)
                .onAppear {
                    parseLocalJSONtoFetchLocations()
                }
            }
            .navigationTitle("Locations")
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
