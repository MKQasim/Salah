//
//  TextFieldMenuView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import SwiftUI

struct PickerTextField: View {
    var listOfItems: [String]
    var placeholder:String
    @Binding var value:String
    @State private var isList = false
    
    
    
    var body: some View {
        VStack{
            HStack{
                TextField(placeholder, text: $value) { isFocused in
                    if isFocused{
                        isList = true
                    }
                }
                Button(action: {
                    isList.toggle()
                }, label: {
                    Label("Drop list of countries", systemImage: "arrow.down.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title)
                })
            }
            if isList{
                ScrollView{
                    LazyVStack{
                        ForEach(listOfItems.filter{value.isEmpty ? true : $0.contains(value)}, id: \.self){dropItem in
                            Text(dropItem)
                                .onTapGesture {
                                    value = dropItem
                                    isList.toggle()
                                }
                                .frame(maxWidth: .infinity,alignment: .leading)
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 150)
            }
        }
    }
    
    init(listOfItems: [String], placeholder: String, value: Binding<String>, isList: Bool = false) {
        self.listOfItems = listOfItems
        self.placeholder = placeholder
        self._value = value
        self.isList = isList
    }
    
}

//#Preview {
//    @State var selectCountry = ""
//
//    PickerTextField(listOfItems: [], placeholder: "Enter Country Name", value: $selectCountry)
//}
