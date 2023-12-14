//
//  PrayerTodaySectionView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct PrayerTodaySectionView: View {
    @Binding var prayerTimes:[SalahTiming]
    @State private var nextPrayerName: String = ""
    @State private var remainingTime: String = ""
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        
        VStack(alignment: .leading){
            LazyVGrid(columns: column, pinnedViews: .sectionHeaders, content: {
                Section(header: VStack{
                    Text("Today's Prayers Times").font(.title3).bold()
                }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                        
                ) {
                    ForEach(prayerTimes, id: \.self) { prayer in
                        PrayerTodayCellView(prayer: prayer)
                    }
                }
            })
        }
    }
}




#Preview {
    @State var prayerTime = [SalahTiming(name: "Fajr", time: "06:00"), SalahTiming(name: "Duhr", time: "12:00"), SalahTiming(name: "Asr", time: "14:00"),SalahTiming(name: "Magrib", time: "17:00"),SalahTiming(name: "Isah", time: "19:00")]
    return PrayerTodaySectionView(prayerTimes: $prayerTime)
}
