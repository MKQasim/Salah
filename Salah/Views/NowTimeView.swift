//
//  NowTimeView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation
import SwiftUI

struct NowTimeView: View {
    var systemName: String
    var color: Color
    var islamicdate : String
    var value: String
    var title: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemName)
                .font(.system(size: 40)) // Fixed size for the icon
                .foregroundColor(color)
                .padding(10)
            Text(title)
                .font(.headline)
            VStack(alignment: .center, spacing: 5) {
                Text(islamicdate)
                    .font(.headline)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 1)
    }
}

#Preview {
    return PrayerSunSection()
}


import SwiftUI

struct SectionHeaderView: View {
    let title:String
    let dateTime : String
    var body: some View {
        HStack{
            Text(title).font(.subheadline)
                .fontWeight(.heavy)
                .foregroundStyle(.gray)
            Spacer()
            Text(dateTime).font(.subheadline)
                .fontWeight(.heavy)
                .foregroundStyle(.gray)
        }
            .frame(maxWidth: .infinity,alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .cornerRadius(10)
    }
}

#Preview {
    let title = "Header"
    return SectionHeaderView(title: title, dateTime: title)
}
