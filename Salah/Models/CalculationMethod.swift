//
//  CalculationMethod.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/21/23.
//

import Foundation

enum CalculationMethod:Int, Hashable, Identifiable, CaseIterable {
    case Jafari    // Ithna Ashari
    case Karachi    // University of Islamic Sciences, Karachi
    case ISNA // Islamic Society of North America (ISNA)
    case MWL   // Muslim World League (MWL)
    case Makkah    // Umm al-Qura, Makkah
    case Egypt    // Egyptian General Authority of Survey
    case Tehran   // Tehran
    case Custom    // Custom Setting
    
    var id: Int {return rawValue}
}
