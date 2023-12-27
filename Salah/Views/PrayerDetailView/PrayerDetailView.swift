//
//  SalahDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//
import SwiftUI

struct PrayerDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var locationState: LocationState
    let currentDate = Date()
    let selectedLocation: Location
    // MARK: View States
    @State private var todayPrayersTimes: [PrayerTiming] = []
    @State private var tomorrowPrayerTimes: [PrayerTiming] = []
    @State private var sunTimes: [PrayerTiming] = []
    @State private var selectedPrayer: PrayerTiming? = nil
    @State private var isUpdate = true
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remainingTime: TimeInterval = 0
    @State private var remTime = "00:00:00"
    @State private var targetDate: Date?

    var body: some View {
        ScrollView(.vertical) {
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
                        .onReceive(timer) { _ in updateTime() }
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(20)
            .frame(minWidth: 140)

            PrayerSunSection(sunTimes: $sunTimes)
            PrayerTodaySectionView(prayerTimes: $todayPrayersTimes, nextSalah: $selectedPrayer)
            PrayerTomorowSection(prayerTimes: $tomorrowPrayerTimes)
            PrayerWeeklySectionView(selectedLocation: selectedLocation)
        }
        .padding(.top, 10)
        .padding([.leading, .trailing])
        .onAppear {
            Task {
                await setUpView()
                startTimer()
            }
        }
    }

    private func setUpView() async {
        if isUpdate {
            todayPrayersTimes = []
            tomorrowPrayerTimes = []
            sunTimes = []
            remTime = "00:00:00"
            let timeZoneOffset = selectedLocation.offSet
            timeNow = updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: selectedLocation.offSet ?? 0.0, calendarIdentifier: .islamicCivil)?.formattedString ?? ""

            await PrayerTimeHelper.shared.getSalahTimings(location: selectedLocation) { location in
                guard let location = location, let nextPrayer = location.nextPrayer, let name = nextPrayer.name, let time = nextPrayer.time?.formatted(date: .omitted, time: .standard) else { return }

                todayPrayersTimes = location.prayerTimings ?? []
                nextSalah = "\(name) at \(time)"
                targetDate = nextPrayer.time

                let startDate = updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: selectedLocation.offSet ?? 0.0, calendarIdentifier: .islamicCivil)?.date ?? Date()
                // Update the remaining time immediately
                updateTimer(startDate, targetDate ?? Date(), withTimeZoneOffset: selectedLocation.offSet ?? 0.0)
            }
            sunTimes = PrayerTimeHelper.shared.getSunTimings(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, timeZone: selectedLocation.offSet ?? 0.0 , date: Date())
            if let cal = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                tomorrowPrayerTimes = PrayerTimeHelper.shared.getSunTimings(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, timeZone: selectedLocation.offSet ?? 0.0, date: Date())
                isUpdate = false
            }
        }
    }
    
    func updatedDateFormatAndTimeZone(for date: Date, withTimeZoneOffset offset: Double, calendarIdentifier: Calendar.Identifier) -> (date: Date, formattedString: String)? {
        let offsetInSeconds = Int(offset * 3600) // Convert hours to seconds

        if let timeZone = TimeZone(secondsFromGMT: offsetInSeconds) {
            var calendar = Calendar(identifier: calendarIdentifier)
            calendar.timeZone = timeZone // Set the calendar's time zone

            if let updatedDate = calendar.date(byAdding: .second, value: offsetInSeconds, to: date) {
                let dateFormatter = DateFormatter()
                dateFormatter.calendar = calendar
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short

                let formattedString = dateFormatter.string(from: updatedDate)
                return (date: updatedDate, formattedString: formattedString)
            } else {
                print("Error converting the date.")
                return nil
            }
        } else {
            print("Invalid offset provided.")
            return nil
        }
    }


    private func updateTime() {
        let timeZoneOffset = selectedLocation.offSet
        let startDate = updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: timeZoneOffset ?? 0.0, calendarIdentifier: .islamicCivil)?.date ?? Date()
        // Update the remaining time immediately
        guard let targetDate = targetDate else { return }
        updateTimer(startDate, targetDate, withTimeZoneOffset: timeZoneOffset ?? 0.0)
    }

    // Your other helper functions remain unchanged

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let targetDate = self.targetDate else { return }
            remainingTime = max(targetDate.timeIntervalSinceNow, 0)
            remTime = "0909:09u098"
//            remTime = String(format: "%02d:%02d:%02d", hoursCom, minutes, secondsCom)
            if remainingTime == 0 {
                // Timer reached zero
//                $timer.invalidate
            }
        }
        .fire()
    }
    
    func updateTimer(_ startDate: Date, _ endDate: Date, withTimeZoneOffset offset: Double) {
            let calendar = Calendar.current

            let offsetInSeconds = Int(offset * 3600) // Convert hours to seconds

            if let timeZone = TimeZone(secondsFromGMT: offsetInSeconds) {
                var targetCalendar = Calendar(identifier: .gregorian)
                targetCalendar.timeZone = timeZone // Set the calendar's time zone

                // Adjust end date based on the offset
                if let updatedEndDate = targetCalendar.date(byAdding: .second, value: offsetInSeconds, to: endDate) {

                    let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: updatedEndDate)

                    let hoursCom = components.hour ?? 0
                    let minutes = components.minute ?? 0
                    let secondsCom = components.second ?? 0

                    print(components)
                    remTime = String(format: "%02d:%02d:%02d", hoursCom, minutes, secondsCom)
                    print("Remaining time: \(remTime)")

                    // Check if the end date is reached
                    if startDate >= updatedEndDate {
                        // Stop the timer when the end date is reached
                        // timer?.invalidate()
//                        getNextPrayerTime()
                    }
                } else {
                    print("Error adjusting end date.")
                }
            } else {
                print("Invalid offset provided.")
            }
        }
}


//#Preview {
//    let city = Cities(city: "Nuremberg", lat: 28.61, long: 77.20, timeZone: +5.5)
//    return PrayerDetailView(city: city)
//        .environmentObject(LocationManager())
//        .environmentObject(LocationState())
//}

