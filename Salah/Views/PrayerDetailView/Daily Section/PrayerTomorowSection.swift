//
//  PrayerTomorowSection.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/13/23.
//

import SwiftUI

struct PrayerTomorowSection: View {
    @Binding var selectedLocation: Location?
    @State private var nextPrayerName: String = ""
    @State private var remainingTime: String = ""
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        LazyVGrid(columns: column, pinnedViews: .sectionHeaders, content: {
            Section(header: SectionHeaderView(title: "Tomorrow Salah Timings")) {
                ForEach(selectedLocation?.tomorrowPrayerTimings ?? [], id: \.self) { prayer in
                    
                    PrayerDailyCellView(prayer: prayer)
                        .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(10)
                        .padding()
                }
            }
        })
    }
}


//#Preview {
//    @State var prayerTime = [PrayerTiming(name: "Fajr", time: Date()), PrayerTiming(name: "Duhr", time: Date()), PrayerTiming(name: "Asr", time: Date()),PrayerTiming(name: "Magrib", time: Date()),PrayerTiming(name: "Isah", time:  Date())]
//    return PrayerTomorowSection(prayerTimes: $prayerTime)
//}
