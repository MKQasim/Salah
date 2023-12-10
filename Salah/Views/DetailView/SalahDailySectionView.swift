//
//  SalahDailySectionView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct SalahDailySectionView: View {
    
    @Binding var prayerTimes:[SalahTiming]
    
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        Section(header: Text("Prayer Times").bold().foregroundColor(.black)) {
            LazyVGrid(columns: column, spacing: 10) {
                ForEach(prayerTimes, id: \.self) { prayer in
                    PrayerItemView(prayer: prayer)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray))
            .padding()
        }
    }
}

struct PrayerItemView: View {
    let prayer: SalahTiming

    var body: some View {
        VStack {
            Image(systemName: "moon.stars.fill")
                .foregroundColor(.purple) // Adjust color as needed
                .font(.title)
            Text(prayer.name)
                .frame(width: 100)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text(prayer.time)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}


//#Preview {
//    @State var prayerTime = [SalahTiming(name: "Fajr", time: "06:00")]
//    SalahDailySectionView(prayerTimes: $prayerTime)
//}
