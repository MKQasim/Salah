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
            VStack{
                VStack(spacing: 10) {
                    if selectedPrayer != nil {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.green)
                                .font(.title2)
                                .fontWeight(.black)
                            
                            Text("Next Prayer in : \(remTime)")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("\(nextSalah)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("\(timeNow)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                    }
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(20)
                .frame(minWidth: 140)
                PrayerSunSection(sunTimes: $sunTimes)
                PrayerTodaySectionView(prayerTimes: $todayPrayersTimes, nextSalah: $selectedPrayer)
                PrayerTomorowSection(selectedLocation: $selectedLocation)
                PrayerWeeklySectionView(selectedLocation: selectedLocation  ?? Location())
            }
            .padding([.leading, .trailing])
        }
        .padding(.top, 10)
        .onAppear{
            Task{
            setUpView()
            updateCounter()
            }
                    
        }
       
#if os(iOS)
.navigationBarTitle(selectedLocation?.city ?? "", displayMode: .automatic)
#endif
//        .task {
//            await setUpView()
//            updateCounter()
//        }
    }
    
    func addLocation() {
        locationState.cities.append(selectedLocation ?? Location())
        if let newSelectedLocation = selectedLocation {
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
            VStack{
                VStack(spacing: 10) {
                    if selectedPrayer != nil {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.green)
                                .font(.title2)
                                .fontWeight(.black)
                            
                            Text("Next Prayer in : \(remTime)")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("\(nextSalah)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("\(timeNow)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                    }
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(20)
                .frame(minWidth: 140)
                PrayerSunSection(sunTimes: $sunTimes)
                PrayerTodaySectionView(prayerTimes: $todayPrayersTimes, nextSalah: $selectedPrayer)
                PrayerTomorowSection(selectedLocation: $selectedLocation)
                PrayerWeeklySectionView(selectedLocation: selectedLocation  ?? Location())
            }
            .padding([.leading, .trailing])
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
//        .task {
//            await setUpView()
//            updateCounter()
//        }
    }
    
    func addLocation() {
        locationState.cities.append(selectedLocation ?? Location())
        if let newSelectedLocation = selectedLocation {
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
