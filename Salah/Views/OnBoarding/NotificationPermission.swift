//
//  NotificationPermission.swift
//  Salah
//
//  Created by Haaris Iqubal on 15.12.23.
//

import SwiftUI

struct NotificationPermission: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @State private var animationAmount = 1.0
    
    var body: some View {
        VStack{
            VStack{
                Text("Get notified for upcoming Salah")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                Text("We do not share your information to any third parties servers and really care for your privacy.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom,20)
            Spacer()
            Image(systemName: "bell.badge.fill")
                .foregroundColor(.red)
                .font(.largeTitle)
                .scaleEffect(animationAmount)
                .animation(
                    .easeInOut(duration: 3),
                    value: animationAmount
                )
                .padding(.bottom,20)
            Spacer()
            VStack(spacing: 15){
//                switch $notificationManager.notificationStatus {
//                case .denied,.authorized,.provisional,.notDetermined:
//                    Button(action: {}, label: {
//                        Text("Next")
//                    })
//                default:
//                    Button(action: {
//                        notificationManager.requestNotification()
//                    }, label: {
//                        Text("Allow notification")
//                    })
//                    .buttonStyle(.borderedProminent)
//                }
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Skip notification")
                })
            }
        }
        .padding()
        .onAppear{
            animationAmount += 2
        }
    }
}

#Preview {
    NotificationPermission()
//        .environmentObject(NotificationManager())
}
