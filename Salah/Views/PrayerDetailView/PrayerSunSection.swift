//
//  SalahSunTimeSection.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct PrayerSunSection: View {
    @Binding var sunTimes: [PrayerTiming]
    
    var body: some View {
        if !sunTimes.isEmpty {
            LazyVGrid(columns: [.init(.flexible(minimum: 150, maximum: .infinity)), .init(.flexible(minimum: 150, maximum: .infinity))], pinnedViews: .sectionHeaders, content: {
                Section(header: SectionHeaderView(title: "Sun Times")) {
                    ForEach(sunTimes, id: \.self) { sunTime in
                        VStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.yellow)
                                .font(.title)
                            HStack {
                                Text("\(sunTime.name ?? "")")
                                Text(": \(sunTime.formatDateString(sunTime.time ?? Date()))")
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: backgroundColors(for: sunTime)), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(20)
                    }
                }
            })
        } else {
            EmptyView()
        }
    }

    private func backgroundColors(for sunTime: PrayerTiming) -> [Color] {
        // Use distinct background colors for sunrise and sunset
        if sunTime.name?.lowercased() == "sunrise" {
            return [Color.black,Color.gray, Color.orange]
        } else if sunTime.name?.lowercased() == "sunset" {
            return [Color.orange, Color.gray,Color.black]
        } else {
            // Default background colors for other sun times
            return [Color.orange, Color.purple]
        }
    }
}


#Preview {
    @State var sunTime = [PrayerTiming(name: "Sun Rise", time: Date()), PrayerTiming(name: "Sun Set", time: Date())]
    return PrayerSunSection(sunTimes: $sunTime)
}
