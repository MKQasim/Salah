//
//  ManualLocationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import SwiftUI
import CoreLocation
import Combine

class Debouncer {
    var delay: TimeInterval
    var cancellable: DispatchWorkItem?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func run(action: @escaping (String) -> Void) -> (String) -> Void {
        return { value in
            self.cancellable?.cancel()
            let newTask = DispatchWorkItem(block: { action(value) })
            self.cancellable = newTask
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay, execute: newTask)
        }
    }
}



extension Binding where Value: Equatable {
    func onChange(perform action: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { newValue in
                if self.wrappedValue != newValue {
                    self.wrappedValue = newValue
                    action(newValue)
                }
            }
        )
    }
}

struct SearchBar: View {
    @Binding var text: String
    @State var debouncer = Debouncer(delay: 0.5)

    var body: some View {
        TextField("Search for a city", text: $text.onChange(perform: { newValue in
            self.debouncer.run(action: { value in
                print(value) // Perform the action here
            })(newValue)
        }))
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
    var onDismiss: ((Location) -> Void)
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
                                        onDismiss(item)
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
                    DispatchQueue.global(qos: .background).async {
                        parseLocalJSONtoFetchLocations()
                    }
                }
            }
            .navigationTitle("Locations")
            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Image("logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100, height: 50)
//                    
//                }
//                ToolbarItem(placement: .principal) {
//                    Image("logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100, height: 50)
//                    
//                }
                
                ToolbarItem(placement: .principal) {
                    HStack {
                        Spacer()
                        Button(action: {
//                            addLocation()
                        }) {
                            Text("Add")
                        }
//                        .disabled(!isLocationAdded) // Disable the button when location is added
                        Spacer()
                    }
                }
                
            }
            
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            addLocation()
//                        }) {
//                            Text(isOpenedAfterSearch ? "Preview" : "Add")
//                        }
//                        .disabled(!isLocationAdded) // Disable the button when location is added
//                        Spacer()
//                    }
//                }
//            }
//            .navigationTitle(selectedLocation?.city ?? "")
        }
    }

    func parseLocalJSONtoFetchLocations() {
        if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                let jsonData = try Data(contentsOf: fileUrl)
                let location = try? JSONDecoder().decode([Location].self, from: jsonData)
                DispatchQueue.main.async {
                    dropDownList = location ?? []
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        } else {
            print("File not found")
        }
    }
}




extension Published.Publisher where Value: Equatable {
    func onChange(perform action: @escaping (Value) -> Void) -> AnyPublisher<Value, Never> {
        self
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: action)
            .eraseToAnyPublisher()
    }
}

#Preview {
    @State var isSheet = false
    @State var isDetailView = true
    
    @State var searching = ""
    return ManualLocationView(searchable: $searching, isDetailView: $isDetailView, onDismiss: {_ in })
        .environmentObject(LocationState())
}
