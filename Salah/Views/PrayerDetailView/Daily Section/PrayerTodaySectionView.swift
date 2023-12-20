//
//  PrayerTodaySectionView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct PrayerTodaySectionView: View {
    @Binding var prayerTimes:[PrayerTiming]
    @Binding var nextSalah:PrayerTiming?
    @State private var remainingTime: String = ""
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        VStack(alignment: .leading){
            LazyVGrid(columns: column, pinnedViews: .sectionHeaders, content: {
                Section(header: SectionHeaderView(title: "Today's Salah Times")) {
                    ForEach(prayerTimes, id: \.self) { prayer in
                        PrayerTodayCellView(prayer: prayer)
                            .padding()
                            .frame(maxWidth: .infinity,minHeight: 120)
                            .background(nextSalah == prayer ? .ultraThickMaterial : .thinMaterial)
                            .cornerRadius(10)
                    }
                }
            })
        }
    }
}




//#Preview {
//    @State var prayerTime = [PrayerTiming(name: "Fajr", time: "06:00"), PrayerTiming(name: "Duhr", time: "12:00"), PrayerTiming(name: "Asr", time: "14:00"),PrayerTiming(name: "Magrib", time: "17:00"),PrayerTiming(name: "Isah", time: "19:00")]
//    @State var selectedPrayer = PrayerTiming(name: "Fajr", time: "6:00")
//    return PrayerTodaySectionView(prayerTimes: $prayerTime)
//}
