//
//  NextPrayerRow.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation
import SwiftUI

struct NextPrayerView: View {
    var systemName: String
    var color: Color
    @Binding var remainingTime: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemName)
                .font(.system(size: 40)) // Fixed size for the icon
                .foregroundColor(color)
                .padding(10)
            
            Text("Next Prayer in \(remainingTime)")
                .font(.headline)
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 1)
    }
}
