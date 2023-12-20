//
//  SectionHeaderView.swift
//  Salah
//
//  Created by Haaris Iqubal on 20/12/2023.
//

import SwiftUI

struct SectionHeaderView: View {
    let title:String
    var body: some View {
        VStack{
            Text(title).font(.subheadline)
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
    return SectionHeaderView(title: title)
}
