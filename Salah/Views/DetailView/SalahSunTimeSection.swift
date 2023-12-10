//
//  SalahSunTimeSection.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct SalahSunTimeSection: View {
    
    @Binding var sunTimes: [SalahTiming]
    
    var body: some View {
        if !sunTimes.isEmpty {
            Section(header: Text("Sun Times").bold().foregroundColor(.black).background(.clear)) {
                HStack{
                    ForEach(sunTimes, id: \.self) { sunTime in
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.yellow)
                        Text("\(sunTime.name): \(sunTime.time)")
                            .foregroundColor(.black)
                            .font(.headline)
                        
                    }
                }
            }
            .padding()
        } else {
            EmptyView()
        }
    }
}

//#Preview {
//    SalahSunTimeSection()
//}
