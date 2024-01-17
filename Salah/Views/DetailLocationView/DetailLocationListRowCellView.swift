//
//  DetailLocationListRowCellView.swift
//  Salah
//
//  Created by Qassim on 1/1/24.
//

import SwiftUI

struct DetailLocationListRowCellView: View {
    @EnvironmentObject var navigationState: NavigationState
    
    @Binding var isFullScreenView: Bool
    
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remTime = ""
    
    var timeManager: TimerManager?
    var timerUpdated: ((String) -> Void)?

    let location: Location?
    let isCurrent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                if isCurrent {
                    navigationState.tabbarSelection = .currentLocation
                } else {
                    navigationState.tabbarSelection = .location(location ?? Location())
                }
                isFullScreenView.toggle()
            }, label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(location?.city ?? ""), \(location?.country ?? "")")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("Current Time: \(timeNow)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Next Prayer: \(nextSalah)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Remaining Time: \(remTime)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
            })
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.sky2)
                .shadow(radius: 3)
        )
        .task {
            setupTimer()
        }
    }
    
    func setupTimer() {
        guard let location = self.location else { return }
        
        self.timeNow = "\(Date().updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: location.timeZoneIdentifier ?? "", calendarIdentifier: .islamicCivil)?.formattedString ?? "")"
        
        let currentDate = Date().getDateFromTimeZoneOffset(timeZoneIdentifier: location.timeZoneIdentifier ?? "")
        let startDate = location.nextPrayer?.updatedDateFormatAndTimeZoneString(for: currentDate, withTimeZoneOffset: location.timeZoneIdentifier ?? "", calendarIdentifier: .gregorian)?.date
        
        guard let endDate = location.nextPrayer?.time, let unwrappedStartDate = startDate else { return }
        
        timeManager?.stopTimer()
        
        startDate?.startCountdownTimer(from: unwrappedStartDate, to: endDate) { formattedTime in
            self.remTime = formattedTime
            self.timerUpdated?(formattedTime)
        }
    }
}

//#Preview {
//    @State var isFullScreenView = false
//    return DetailLocationListRowCellView(isFullScreenLocation: $isFullScreenView)
//}
