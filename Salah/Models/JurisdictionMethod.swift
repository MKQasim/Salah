//
//  JuridictionMethod.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/21/23.
//

import Foundation

enum JurisdictionMethod: Int, Hashable, Identifiable, CaseIterable {
    case Shafii
    case Hanafi
    
    var id: Int {
        return rawValue
    }
}
