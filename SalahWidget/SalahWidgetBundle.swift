//
//  SalahWidgetBundle.swift
//  SalahWidget
//
//  Created by Qassim on 12/13/23.
//

import WidgetKit
import SwiftUI

@main
struct SalahWidgetBundle: WidgetBundle {
    var body: some Widget {
        SalahWidget()
        SalahWidgetLiveActivity()
    }
}
