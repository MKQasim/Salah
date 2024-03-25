//
//  PermissionBoard.swift
//  Salah
//
//  Created by Haaris Iqubal on 15.12.23.
//

import SwiftUI

struct PermissionBoard: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var notificationManager: NotificationManager
    var body: some View {
        NavigationStack{
            VStack{
                Text("We care about your privacy")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .multilineTextAlignment(.center)
                Image(systemName: "hand.raised.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text("Allow which feature you want to enable for this app.")
                    .frame(maxWidth: 160)
                    .multilineTextAlignment(.center)
                Spacer()
                VStack(spacing: 20){
                    HStack{
                        getlocationStatus()
                    }
                    HStack{
//                        getNotificationStatus()
                    }
                }
                .frame(maxWidth: .infinity,minHeight: 200)
                .background(.gray.opacity(0.2))
                .cornerRadius(20)
                .padding()
                
                Spacer()
                Button(action: {}, label: {
                    Text("Skip")
                        .frame(minWidth: 200)
                })
                .buttonStyle(.borderedProminent)
                .tint(.gray)
            }
        }
    }
    
    func getlocationStatus() -> some View{
        switch locationManager.locationStatus {
        case .notDetermined:
            LocationPermissionButtonView(image: "circle", checkBoxColor: .gray, buttonColor: .blue)
        case .restricted, .denied:
            LocationPermissionButtonView(image: "circle", checkBoxColor: .red, buttonColor: .red)
        case .authorizedAlways, .authorizedWhenInUse:
            LocationPermissionButtonView(image: "checkmark.circle.fill", checkBoxColor: .green, buttonColor: .green)
#if !os(watchOS)
        case .authorized:
            LocationPermissionButtonView(image: "checkmark.circle", checkBoxColor: .green, buttonColor: .green)
#endif
        default:
            LocationPermissionButtonView(image: "circle", checkBoxColor: .gray, buttonColor: .gray)
        }
    }
    
//    func getNotificationStatus()-> some View{
//        switch notificationManager.$isNotificationEnabled {
//        case .notDetermined:
//            NotificationPermissionButtonView(image: "cicle", checkBoxColor: .gray, buttonColor: .blue)
//        case .denied:
//            NotificationPermissionButtonView(image: "cicle", checkBoxColor: .red, buttonColor: .red)
//        case .authorized, .provisional:
//            NotificationPermissionButtonView(image: "checkmark.circle.fill", checkBoxColor: .green, buttonColor: .green)
//#if !os(watchOS)
//        case .ephemeral:
//            NotificationPermissionButtonView(image: "circle", checkBoxColor: .green, buttonColor: .green)
//#endif
//        default:
//            NotificationPermissionButtonView(image: "cicle", checkBoxColor: .gray, buttonColor: .blue)
//        }
//    }
}


struct LocationPermissionButtonView: View {
    let image:String
    let checkBoxColor: Color
    let buttonColor: Color
    var body: some View{
        Image(systemName: image)
            .foregroundColor(checkBoxColor)
            .font(.title)
        NavigationLink("Location Permission", destination: LocationPermissionOnboard())
            .padding([.top,.bottom],10)
            .frame(minWidth: 250)
            .background(buttonColor)
            .foregroundColor(.white)
            .cornerRadius(5)
    }
}

struct NotificationPermissionButtonView: View {
    let image:String
    let checkBoxColor: Color
    let buttonColor: Color
    var body: some View {
        Image(systemName: "circle")
            .foregroundColor(.gray)
            .font(.title)
        NavigationLink("Notification", destination: NotificationPermission())
            .padding([.top,.bottom],10)
            .frame(minWidth: 250)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(5)
    }
}
#Preview {
    PermissionBoard()
        .environmentObject(LocationManager.shared)
//        .environmentObject(NotificationManager())
}
