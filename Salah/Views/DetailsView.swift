//
//  DetailsView.swift
//  Salah
//
//  Created by Muhammad's on 18.03.24.
//

import Foundation
import SwiftUI
import SwiftData

// MARK: - DetailView

extension View {
    func startCountdown(nextPrayerTimeString: String, timeZone: TimeZone, completion: @escaping (String, String , String) -> Void) {
        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let components = nextPrayerTimeString.split(separator: ":")
        guard components.count == 2,
              let prayerHour = Int(components[0]),
              let prayerMinute = Int(components[1]) else {
            print("Invalid prayer time format")
            return
        }

        var nextPrayerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        nextPrayerDateComponents.timeZone = timeZone // Apply timezone to the date components

        guard let currentDatebytimeZoned = calendar.date(from: nextPrayerDateComponents) else {
            print("Failed to create current date")
            return
        }

        nextPrayerDateComponents.hour = prayerHour
        nextPrayerDateComponents.minute = prayerMinute
        nextPrayerDateComponents.second = 0

        guard var nextPrayerDate = calendar.date(from: nextPrayerDateComponents) else {
            print("Failed to create next prayer date")
            return
        }

        // If nextPrayerDate is in the past, add one day to it
        if nextPrayerDate < currentDatebytimeZoned {
            nextPrayerDateComponents.day! += 1
            guard let newNextPrayerDate = calendar.date(from: nextPrayerDateComponents) else {
                print("Failed to create next prayer date")
                return
            }
            nextPrayerDate = newNextPrayerDate
        }

        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // Update the current date and time
            let currentDateTime = Date()
            let remainingTimeComponents = calendar.dateComponents([.year,.month,.day,.hour, .minute, .second], from: currentDateTime, to: nextPrayerDate)
            var islamic = Calendar(identifier: .islamicCivil)
            islamic.timeZone = timeZone // Apply timezone to the Islamic calendar
            let components = islamic.dateComponents([.year, .month, .day,.hour,.minute,.second], from: currentDateTime)

            guard let hours = remainingTimeComponents.hour, let minutes = remainingTimeComponents.minute, let seconds = remainingTimeComponents.second else {
                return
            }
            
            
            let remainingTimeString = String(format: "%02d:%02d:%02d", max(00, hours), max(00, minutes), max(00, seconds))
            
            let currentTimeString = String(format: "%02d:%02d:%02d", max(00, components.hour ?? 0), max(00, components.minute ?? 0), max(00, components.second ?? 0))

            completion(remainingTimeString,"\(currentTimeString)", "\(currentDateTime.getIslamicDate(from: currentDateTime, timeZone: timeZone))")
        }
        RunLoop.current.add(timer, forMode: .common)
    }
}

struct DetailView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var prayerTask: Task<(), Error>?
    @State private var showSettings = false
    @State private var remainingTime = ""
    @State private var currentTime = ""
    @State private var currentDate = ""
    var formattedCurrentTime: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: viewModel.selectedItem?.timeZoneIdentifier ?? "Berlin")
        formatter.dateFormat = "h:mm a"
        let currentTimeString = formatter.string(from: Date())
        
        guard let nextPrayerTimeString = viewModel.prayer?.nextPrayer?.time,
              let nextPrayerTime = formatter.date(from: nextPrayerTimeString),
              let currentTime = formatter.date(from: currentTimeString) else {
            return currentTimeString
        }
        
        let remainingTime = nextPrayerTime.timeIntervalSince(currentTime)
        let remainingTimeString = String(format: "%.0f", remainingTime)
        
        return "\(currentTimeString) (\(remainingTimeString)s remaining)"
    }
    
    private var debugNextPrayerName: String {
        if let nextPrayer = viewModel.prayer?.nextPrayer {
            return "\((nextPrayer.name ?? "")  +  (nextPrayer.time ?? ""))"
        } else {
            return "No next prayer available"
        }
        ""
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 5) {
                    Text("Location at \(viewModel.selectedItem?.city ?? ""), \(viewModel.selectedItem?.timeZoneIdentifier ?? "")")
                        .padding(.all, 15)
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.gray, .blue]),
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(radius: 10)
                        .cornerRadius(10)
                        .onTapGesture {
                            print("Location tapped")
                        }
                    
                    VStack(spacing: 0) {
                        VStack {
                            PrayerInfoView(systemName: "timer", title: "Next Prayer: ", value: "\(viewModel.prayer?.nextPrayer?.name ?? "") at \( (viewModel.prayer?.nextPrayer?.time ?? "") ?? "")", gradientColors: [.green, .blue])
                           
                            NextPrayerView(systemName: "clock.arrow.circlepath", color: .yellow, remainingTime: $remainingTime)
                                             
                            NowTimeView(systemName: "calendar", color: .pink, islamicdate: currentTime, value: currentDate, title: "Current Date & Time ")
                        }
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        
                        PrayerSunSection()
                        PrayerSectionView(day: viewModel.prayer?.today, title: "Today's Salah Times")
                        PrayerSectionView(day: viewModel.prayer?.tomorrow, title: "Tomorrow's Salah Times")

                        WeeklyPrayerTimingsGridView()
                    }.id(viewModel.prayer)
                        .padding([.leading, .trailing])
                        .padding(.top, 10)
                    
                    // Progress view to show while loading
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.45))
                            .edgesIgnoringSafeArea(.all)
                    }
                  
                }
                .navigationTitle(viewModel.tabViewModel.tapTitle)
                .frame(width: geometry.size.width)
                .onChange(of: viewModel.prayer) { _,newValue in
                    print(newValue)
                    viewModel.isLoading = false
                    
                    if let timeZone = TimeZone(identifier: viewModel.prayer?.nextPrayer?.timeZoneIdentifier ?? ""){
                        startCountdown(nextPrayerTimeString: viewModel.prayer?.nextPrayer?.time ?? "00:00", timeZone: timeZone) { time, currentdate , currenttime   in
                            remainingTime = time
                            currentTime = currenttime
                            currentDate = currentdate
                            print(time)
                            print(currenttime)
                        }
                    }
                    
                    prayerTask?.cancel()
                }
                .onChange(of: viewModel.selectedItem) { _,_ in
                    viewModel.isLoading = false
                    prayerTask?.cancel()
                    prayerTask = Task {
                        prayerTask?.cancel()
                        print("viewModel.selectedItem : \(viewModel.selectedItem)")
                        try?  await viewModel.fetchPrayers(location: viewModel.selectedItem)
                    }
                }
            }
            .onAppear {
                prayerTask = Task {
                    prayerTask?.cancel()
                    print("viewModel.selectedItem : \(viewModel.selectedItem)")
                    try?  await viewModel.fetchPrayers(location: viewModel.selectedItem)
                }
            }
            .onDisappear {
                // Cancel the ongoing prayer fetching task when the view disappears
                prayerTask?.cancel()
            }
            
            .toolbar {
                //                let locationManager = LocationManager() // Replace with your actual LocationManager initialization
                //                let notificationManager = NotificationManager.shared // Replace with your actual NotificationManager initialization
                //                let fileStorageManager = FileStorageManager() // Replace with your actual FileStorageManager initialization
                //                let settingsService = SettingsRepository(fileStorageManager: fileStorageManager)
                //
                //                let mockPermissionsManager = PermissionsManager(
                //                    locationManager: locationManager,
                //                    notificationManager: notificationManager,
                //                    settingsService: settingsService
                //                )
                //                NavigationLink(destination: SettingsView(permissionsManager: mockPermissionsManager), isActive: $showSettings) {
                //                    Button(action: {
                //                        showSettings.toggle()
                //                    }) {
                //                        Image(systemName: "gearshape.fill")
                //                    }
                //                }
            }
            .help("Settings")
            
        }
    }
}

import SwiftUI

struct DetailView_Previews: PreviewProvider {
    static var viewModel: ContentViewModel = {
        // Create the schema
        let schema = Schema([
            PrayerPlace.self,
        ])
        
        // Configure the model container
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        // Create the sharedModelContainer
        let sharedModelContainer: ModelContainer
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        // Initialize and return the viewModel
        return ContentViewModel(context: sharedModelContainer.mainContext)
    }()
    
    static var previews: some View {
        Group {
            DetailView()
                .environmentObject(viewModel)
                .environmentObject(Theme()) // Provide a dummy Theme
                .preferredColorScheme(.light) // Set preferred color
            DetailView()
                .environmentObject(viewModel)
                .environmentObject(Theme()) // Provide a dummy Theme
                .preferredColorScheme(.dark) // Set preferred color scheme
        }
    }
}


// MARK: - ListItem

struct ListItem: View {
    let item: PrayerPlace
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.city ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                //                Text(item.timeZoneIdentifier, format: Date.FormatStyle(date: .numeric, time: .standard))
                Text(item.country ?? "")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [.gray, .blue]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}


