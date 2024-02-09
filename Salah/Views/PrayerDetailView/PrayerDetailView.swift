//
//  SalahDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//
import SwiftUI


struct PrayerDetailView: View {
    // MARK: View States
    @EnvironmentObject private var locationState: LocationState
    @EnvironmentObject private var navigationState: NavigationState
    @State var selectedLocation: Location?
    @Binding var isDetailViewPresented: Bool // Binding to manage presentation
    var onDismiss: (() -> Void)?
    @State private var isLocationAdded = false
    
    @State private var todayPrayersTimes: [PrayerTiming] = []
    @State private var tomorrowPrayerTimes: [PrayerTiming] = []
    @State private var sunTimes: [PrayerTiming] = []
    @State private var selectedPrayer: PrayerTiming? = nil
    @State private var isUpdate = true
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remainingTime: TimeInterval = 0
    @State private var remTime : String = "00:00:00"
    @State private var targetDate: Date?
    @State private var startDate: Date?
    @State private var countdownValue1: String = "00:00:00"
    let currentDate = Date()
    @Environment(\.presentationMode) private var presentationMode
    @State private var isOpenedAfterSearch = false
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20) {
                VStack {
                    if let selectedPrayer = selectedPrayer {
                        PrayerInfoView(systemName: "timer", title: "Next Prayer in", value: remTime, gradientColors: [.green, .blue])
                    }
                    
                    FeatureRow(systemName: "clock.arrow.circlepath", color: .yellow, title: "Next Prayer", value: nextSalah)
                    FeatureRow(systemName: "calendar", color: .pink, title: "Current Time", value: timeNow)
                }
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(20)
                .shadow(radius: 5)
                PrayerSunSection(sunTimes: $sunTimes)
                PrayerTodaySectionView(selectedLocation: $selectedLocation, nextSalah: $selectedPrayer)
                PrayerTomorowSection(selectedLocation: $selectedLocation)
                PrayerWeeklySectionView(selectedLocation: selectedLocation ?? Location())
            }
            .padding([.leading, .trailing])
            .padding(.top, 10)
            .onAppear {
                Task {
                    await setUpView()
                    updateCounter()
                }
            }
        }
        .navigationBarTitle(selectedLocation?.city ?? "", displayMode: .automatic)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 50)
                
            }
        }
    }
    
    func addLocation() {
        
        if let newSelectedLocation = selectedLocation {
            locationState.updateCities(with: newSelectedLocation)
            navigationState.tabbarSelection = .location(newSelectedLocation)
            navigationState.sidebarSelection = .location(newSelectedLocation)
        }
        isDetailViewPresented = false // Dismiss the PrayerDetailView
        onDismiss?()
        presentationMode.wrappedValue.dismiss()
        
        // Set the flag to true after adding the location
        isLocationAdded = true
    }
    
    
    
    
    func updateCounter() {
        timeNow = "\(Date().updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: selectedLocation?.timeZoneIdentifier ?? "", calendarIdentifier: .islamicCivil)?.formattedString ?? "")"
        
        let currentDate = Date().getDateFromTimeZoneOffset(timeZoneIdentifier: selectedLocation?.timeZoneIdentifier ?? "")
        let startDate = selectedPrayer?.updatedDateFormatAndTimeZoneString(for: currentDate, withTimeZoneOffset: selectedLocation?.timeZoneIdentifier ?? "", calendarIdentifier: .gregorian)?.date
        print("currentDate \(currentDate)")
        print("startDate \(startDate)")
        
        guard let endDate = targetDate, let unwrappedStartDate = startDate else { return }
        
        startDate?.startCountdownTimer(
            from: unwrappedStartDate,
            to: endDate,
            onUpdate: { formattedTime in
                self.remTime = formattedTime
                print("remTime \(remTime)")
                
            }
        )
    }
    
    
    func getNextPrayerTime(_ startDate: Date) -> (() -> (Date?, Date?)) {
        return {
            var nextTimerStartDate: Date?
            var nextPrayerEndDate: Date?
            
            PrayerTimeHelper.shared.getNextPrayerTime(for: selectedLocation ?? Location(), todaysPrayerTimes: self.todayPrayersTimes, tomorrowPrayerTimes: self.tomorrowPrayerTimes) { nextPrayer, difference in
                selectedLocation?.nextPrayer = nextPrayer
                selectedLocation?.timeDifference = difference ?? 0.0
                nextPrayerEndDate = nextPrayer?.time
                nextTimerStartDate = startDate // Set nextTimerStartDate value
            }
            return (nextTimerStartDate, nextPrayerEndDate)
        }
    }
    
    private func setUpView()  {
        if isUpdate {
            todayPrayersTimes = []
            tomorrowPrayerTimes = []
            sunTimes = []
            remTime = "00:00:00"
            print(selectedLocation)
            PrayerTimeHelper.shared.getSalahTimings(location: selectedLocation ?? Location()) { location in
                guard let location = location, let nextPrayer = location.nextPrayer, let name = nextPrayer.name, let time = nextPrayer.time else { return }
                
                selectedLocation = location
                todayPrayersTimes = location.todayPrayerTimings ?? []
                tomorrowPrayerTimes = location.tomorrowPrayerTimings ?? []
                sunTimes = location.todaySunTimings ?? []
                nextSalah = "\(name) at \(nextPrayer.formatDateString(time))"
                selectedPrayer = nextPrayer
                targetDate = nextPrayer.time
                
                if let row = locationState.cities.firstIndex(where: {$0.id == location.id}){
                    locationState.cities[row] = location
                }
            }
            if Calendar.current.date(byAdding: .day, value: 1, to: currentDate) != nil {
                tomorrowPrayerTimes = PrayerTimeHelper.shared.getSunTimings(lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0, timeZone: selectedLocation?.offSet ?? 0.0, date: Date())
                isUpdate = false
            }
        }
    }
}

struct FeatureRow: View {
    var systemName: String
    var color: Color
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [.gray,.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .cornerRadius(20)
        )
    }
}

struct PrayerInfoView: View {
    var systemName: String
    var title: String
    var value: String
    var gradientColors: [Color]
    
    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(.green)
                .font(.title2)
                .fontWeight(.black)
            
            Text("\(title): \(value)")
                .font(.title2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
                .cornerRadius(20)
        )
    }
}

struct PrayerDetailViewPreview: View {
    // MARK: View States
    @EnvironmentObject private var locationState: LocationState
    @EnvironmentObject private var navigationState: NavigationState
    @State var selectedLocation: Location?
    @Binding var isDetailViewPresented: Bool // Binding to manage presentation
    var onDismiss: (() -> Void)?
    @State private var isLocationAdded = false
    @State private var todayPrayersTimes: [PrayerTiming] = []
    @State private var tomorrowPrayerTimes: [PrayerTiming] = []
    @State private var sunTimes: [PrayerTiming] = []
    @State private var selectedPrayer: PrayerTiming? = nil
    @State private var isUpdate = true
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remainingTime: TimeInterval = 0
    @State private var remTime : String = "00:00:00"
    @State private var targetDate: Date?
    @State private var startDate: Date?
    @State private var countdownValue1: String = "00:00:00"
    let currentDate = Date()
    @Environment(\.presentationMode) private var presentationMode
    @State private var isOpenedAfterSearch = false
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20) {
                VStack {
                    if let selectedPrayer = selectedPrayer {
                        PrayerInfoView(systemName: "timer", title: "Next Prayer in", value: remTime, gradientColors: [.green, .blue])
                    }
                    
                    FeatureRow(systemName: "clock.arrow.circlepath", color: .yellow, title: "Next Prayer", value: nextSalah)
                    FeatureRow(systemName: "calendar", color: .pink, title: "Current Time", value: timeNow)
                }
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    
                )
                .cornerRadius(20)
                .shadow(radius: 5)
                
                PrayerSunSection(sunTimes: $sunTimes)
                PrayerTodaySectionView(selectedLocation: $selectedLocation, nextSalah: $selectedPrayer)
                PrayerTomorowSection(selectedLocation: $selectedLocation)
                PrayerWeeklySectionView(selectedLocation: selectedLocation ?? Location())
            }
            .padding([.leading, .trailing])
            .padding(.top, 10)
            .onAppear {
                Task {
                    await setUpView()
                    updateCounter()
                }
            }
        }
        .padding(.top, 10)
        .onAppear{
            Task{
                setUpView()
                updateCounter()
            }
            
        }
        
#if os(iOS)
        .navigationBarItems(trailing:
                                Button(action: {
            addLocation()
        }) {
            Text(isOpenedAfterSearch ? "Preview" : "Add")
        }
            .disabled(isLocationAdded) // Disable the button when location is added
                            
        )
        .navigationBarTitle(selectedLocation?.city ?? "", displayMode: .automatic)
#endif
        
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 50)
                
            }
        }
    }
    
    func addLocation() {
        
        if let newSelectedLocation = selectedLocation {
            navigationState.tabbarSelection = .location(newSelectedLocation)
            navigationState.sidebarSelection = .location(newSelectedLocation)
            locationState.updateCities(with: newSelectedLocation)
        }
        isDetailViewPresented = false // Dismiss the PrayerDetailView
        onDismiss?()
        presentationMode.wrappedValue.dismiss()
        
        // Set the flag to true after adding the location
        isLocationAdded = true
    }
    
    func updateCounter() {
        timeNow = "\(Date().updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: selectedLocation?.timeZoneIdentifier ?? "", calendarIdentifier: .islamicCivil)?.formattedString ?? "")"
        
        let currentDate = Date().getDateFromTimeZoneOffset(timeZoneIdentifier: selectedLocation?.timeZoneIdentifier ?? "")
        let startDate = selectedPrayer?.updatedDateFormatAndTimeZoneString(for: currentDate, withTimeZoneOffset: selectedLocation?.timeZoneIdentifier ?? "", calendarIdentifier: .gregorian)?.date
        
        guard let endDate = targetDate, let unwrappedStartDate = startDate else { return }
        
        startDate?.startCountdownTimer(
            from: unwrappedStartDate,
            to: endDate,
            onUpdate: { formattedTime in
                self.remTime = formattedTime
            }
        )
    }
    
    
    func getNextPrayerTime(_ startDate: Date) -> (() -> (Date?, Date?)) {
        return {
            var nextTimerStartDate: Date?
            var nextPrayerEndDate: Date?
            
            PrayerTimeHelper.shared.getNextPrayerTime(for: selectedLocation ?? Location(), todaysPrayerTimes: self.todayPrayersTimes, tomorrowPrayerTimes: self.tomorrowPrayerTimes) { nextPrayer, difference in
                selectedLocation?.nextPrayer = nextPrayer
                selectedLocation?.timeDifference = difference ?? 0.0
                nextPrayerEndDate = nextPrayer?.time
                nextTimerStartDate = startDate // Set nextTimerStartDate value
            }
            return (nextTimerStartDate, nextPrayerEndDate)
        }
    }
    
    private func setUpView()  {
        if isUpdate {
            todayPrayersTimes = []
            tomorrowPrayerTimes = []
            sunTimes = []
            remTime = "00:00:00"
            print(selectedLocation)
            PrayerTimeHelper.shared.getSalahTimings(location: selectedLocation ?? Location()) { location in
                guard let location = location, let nextPrayer = location.nextPrayer, let name = nextPrayer.name, let time = nextPrayer.time else { return }
                
                selectedLocation = location
                todayPrayersTimes = location.todayPrayerTimings ?? []
                tomorrowPrayerTimes = location.tomorrowPrayerTimings ?? []
                sunTimes = location.todaySunTimings ?? []
                nextSalah = "\(name) at \(nextPrayer.formatDateString(time))"
                selectedPrayer = nextPrayer
                targetDate = nextPrayer.time
                
                if let row = locationState.cities.firstIndex(where: {$0.id == location.id}){
                    locationState.cities[row] = location
                }
            }
            if Calendar.current.date(byAdding: .day, value: 1, to: currentDate) != nil {
                tomorrowPrayerTimes = PrayerTimeHelper.shared.getSunTimings(lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0, timeZone: selectedLocation?.offSet ?? 0.0, date: Date())
                isUpdate = false
            }
        }
    }
}

//#Preview {
//    let city = Cities(city: "Nuremberg", lat: 28.61, long: 77.20, timeZone: +5.5)
//    return PrayerDetailView(city: city)
//        .environmentObject(LocationManager())
//        .environmentObject(LocationState())
//}
