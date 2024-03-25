//
//  ChooseCityView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation
import SwiftUI

struct ChooseCityView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var searchText = ""
    @State private var selectedCity: PrayerPlace? = nil
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var locations: [PrayerPlace] = []
    @State private var filteredLocations: [PrayerPlace] = []
    @State private var isLoading = false
    @State private var currentPage = 1
    @State private var shouldLoadMore = false // New state variable to trigger loading more locations
    var onDismiss: () -> Void // Callback to handle dismissal
    let pageSize = 10
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                HStack {
                    Spacer()
                    Text("Available Cities \(viewModel.addedLocationsCount)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(5)
                
                SearchBar(text: $searchText) {
                    triggerSearch()
                }
                .padding(5)
                
                GeometryReader { geometry in
                    ScrollView {
                        ScrollViewReader { scrollView in
                            LazyVStack {
                                ForEach(filteredLocations.prefix(currentPage * pageSize), id: \.self) { location in
                                    HStack {
                                        ListItem(item: location)
                                        Spacer()
                                        
                                        if location == selectedCity {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedCity = location
                                        viewModel.addItem(location)
                                        viewModel.tabViewModel.isListMode = true
                                        presentationMode.wrappedValue.dismiss() // Dismiss ChooseCityView
                                        onDismiss() // Perform callback
                                    }
                                    .onAppear {
                                        shouldLoadMore = true
                                        if location == filteredLocations.prefix(currentPage * pageSize).last && !isLoading && shouldLoadMore {
                                            isLoading = true
                                            loadMoreLocations()
                                            isLoading = false
                                            shouldLoadMore = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .cornerRadius(20)
                .padding(.horizontal, 16)
            }
        }
        .padding()
        .background(Color.white)
        .onAppear {
            isLoading = true
            Task {
                await parseLocalJSONtoFetchLocationsIfNeeded()
                isLoading = false
                shouldLoadMore = locations.count > pageSize // Update shouldLoadMore based on the initial data
            }
        }
    }
    
    private func parseLocalJSONtoFetchLocationsIfNeeded() async {
        guard let path = Bundle.main.path(forResource: "cities", ofType: "json") else { return }
        
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
            let decodedData = try JSONDecoder().decode([PrayerPlace].self, from: jsonData)
            
            DispatchQueue.main.async {
                locations = decodedData
                filteredLocations = decodedData
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
    
    private func triggerSearch() {
        if searchText.isEmpty {
            filteredLocations = locations
        } else {
            filteredLocations = locations.filter { $0.city?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
    }
    
    private func loadMoreLocations() {
        let nextPage = currentPage + 1
        let startIndex = nextPage * pageSize
        let endIndex = min(filteredLocations.count, (nextPage + 1) * pageSize) // Adjusted endIndex calculation
        
        if startIndex < endIndex {
            currentPage = nextPage
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Button(action: {
                // Perform search action
                onSearchButtonClicked()
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
    }
}


