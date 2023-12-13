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
            VStack(alignment: .center){
                Section(header: Text("Sun Times").bold()) {
                    VStack{
                        LazyVGrid(columns: [.init(.flexible(minimum: 150)), .init(.flexible(minimum: 150))], content: {
                            ForEach(sunTimes, id: \.self) { sunTime in
                                VStack{
                                    Image(systemName: "sun.max.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title)
                                    Text("\(sunTime.name): \(sunTime.time)")
                                        .foregroundColor(.black)
                                        .font(.headline)
                                }
                                .padding()
                                .background(.thinMaterial)
                                .cornerRadius(20)
                                
                            }
                        })
                    }
                }
            } .padding()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    @State var sunTime = [SalahTiming(name: "Sun Rise", time: "8:00"), SalahTiming(name: "Sun Set", time: "18:00")]
    return PrayerHeaderSection(sunTimes: $sunTime)
}
