//
//  SectionHeaderView.swift
//  Salah
//
//  Created by Haaris Iqubal on 20/12/2023.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [.gray, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(10)
    }
}




#Preview {
    let title = "Header"
    return SectionHeaderView(title: title)
}
