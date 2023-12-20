//
//  PrayerTomorowSection.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/13/23.
//

import SwiftUI

struct PrayerTomorowSection: View {
    @Binding var prayerTimes:[PrayerTiming]
    @State private var nextPrayerName: String = ""
    @State private var remainingTime: String = ""
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        LazyVGrid(columns: column, pinnedViews: .sectionHeaders,content: {
            Section(header: SectionHeaderView(title: "Tomorrow Salah Timings")){
                ForEach(prayerTimes, id: \.self) { prayer in
                    PrayerDailyCellView(prayer: prayer)
                }
            }
        })
        
    }
}

#Preview {
    @State var prayerTime = [PrayerTiming(name: "Fajr", time: "06:00"), PrayerTiming(name: "Duhr", time: "12:00"), PrayerTiming(name: "Asr", time: "14:00"),PrayerTiming(name: "Magrib", time: "17:00"),PrayerTiming(name: "Isah", time: "19:00")]
    return PrayerTomorowSection(prayerTimes: $prayerTime)
}
