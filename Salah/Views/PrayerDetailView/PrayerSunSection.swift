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
            LazyVGrid(columns: [.init(.flexible(minimum: 150,maximum: .infinity)), .init(.flexible(minimum: 150,maximum: .infinity))], pinnedViews: .sectionHeaders,content: {
                Section(header: SectionHeaderView(title: "Sun Times")
                ){
                    ForEach(sunTimes, id: \.self) { sunTime in
                        VStack{
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.yellow)
                                .font(.title)
                            HStack{
                                Text("\(sunTime.name ?? "")")
                                Text(": \(sunTime.formatDateString(sunTime.time ?? Date()))")
                                    .foregroundStyle(.gray)
                            }
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                        .cornerRadius(20)
                        
                    }
                }
            })
        } else {
            EmptyView()
        }
    }
}

#Preview {
    @State var sunTime = [PrayerTiming(name: "Sun Rise", time: Date()), PrayerTiming(name: "Sun Set", time: Date())]
    return PrayerSunSection(sunTimes: $sunTime)
}
