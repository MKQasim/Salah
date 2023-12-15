//
//  SalahSunTimeSection.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct PrayerHeaderSection: View {
    @Binding var sunTimes: [SalahTiming]
    
    var body: some View {
        if !sunTimes.isEmpty {
            LazyVGrid(columns: [.init(.flexible(minimum: 150,maximum: .infinity)), .init(.flexible(minimum: 150,maximum: .infinity))], pinnedViews: .sectionHeaders,content: {
                Section(header: VStack{
                    Text("Sun Times").font(.title3).bold()
                }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                        
                ){
                    ForEach(sunTimes, id: \.self) { sunTime in
                        VStack{
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.yellow)
                                .font(.title)
                            Text("\(sunTime.name): \(sunTime.time)")
                                .font(.headline)
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
    @State var sunTime = [SalahTiming(name: "Sun Rise", time: "8:00"), SalahTiming(name: "Sun Set", time: "18:00")]
    return PrayerHeaderSection(sunTimes: $sunTime)
}
