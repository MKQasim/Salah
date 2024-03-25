//
//  PrayerInfoView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation
import SwiftUI

struct PrayerInfoView: View {
    var systemName: String
    var title: String
    var value: String
    var gradientColors: [Color]

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemName)
                .font(.system(size: 40)) // Fixed size for the icon
                .foregroundColor(.white)
                .padding(10)
                .background(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom))
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 1)
    }
}
