//
//  NotificationManager.swift
//  Salah
//
//  Created by Haaris Iqubal on 15.12.23.
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: NSObject, ObservableObject {
    private let notificationManager = UNUserNotificationCenter.current()
    @Published var notificationStatus: UNAuthorizationStatus?
    
    override init() {
        super.init()
        notificationManager.delegate = self
    }
    
    var statusString: String{
        guard let status = notificationStatus else {
            return "Unknown"
        }
        switch status {
        case .notDetermined:
            return "Not  Determined"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }
    
    func requestNotification() {
        notificationManager.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: {
            granted, error in
            if let error = error {
                print(error.localizedDescription)
            }
            DispatchQueue.main.sync {
                if granted {
                    self.notificationStatus = .authorized
                }
                else{
                    self.notificationStatus = .denied
                }
            }
            
        })
    }
    
    func getNotificationSetting() {
        notificationManager.getNotificationSettings(completionHandler:{ (setting) in
            print(setting.authorizationStatus.rawValue)
            DispatchQueue.main.async {
                switch setting.authorizationStatus {
                case .notDetermined:
                    self.notificationStatus = .notDetermined
                case .denied:
                    self.notificationStatus = .denied
                case .authorized:
                    self.notificationStatus = .authorized
                case .provisional:
                    self.notificationStatus = .provisional
    #if !os(macOS) && !os(watchOS)
                case .ephemeral:
                    self.notificationStatus = .ephemeral
    #endif
                @unknown default:
                    self.notificationStatus = .none
                }
                print(self.notificationStatus?.rawValue)
            }
            
        })
    }
    
}

extension NotificationManager: UNUserNotificationCenterDelegate{
    func notificationCenterDidChangeAuthorization(_ center: UNUserNotificationCenter){
        center.getNotificationSettings(completionHandler: { (setting) in
            self.notificationStatus = setting.authorizationStatus
        })
    }
}
