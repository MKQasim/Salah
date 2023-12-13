//
//  PrayerTomorowSection.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/13/23.
//

import SwiftUI

struct PrayerTomorowSection: View {
    @Binding var prayerTimes:[SalahTiming]
    @State private var nextPrayerName: String = ""
    @State private var remainingTime: String = ""
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        LazyVGrid(columns: column, pinnedViews: .sectionHeaders,content: {
            Section(header: VStack{
                Text("Tomorrow Prayers Times").font(.title3).bold()
            }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                    
            ){
                ForEach(prayerTimes, id: \.self) { prayer in
                    PrayerDailyCellView(prayer: prayer)
                }
            }
        })
        
    }
}

#Preview {
    @State var prayerTime = [SalahTiming(name: "Fajr", time: "06:00"), SalahTiming(name: "Duhr", time: "12:00"), SalahTiming(name: "Asr", time: "14:00"),SalahTiming(name: "Magrib", time: "17:00"),SalahTiming(name: "Isah", time: "19:00")]
    return PrayerTomorowSection(prayerTimes: $prayerTime)
}