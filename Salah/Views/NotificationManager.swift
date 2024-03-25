//
//  NotificationManager.swift
//  Salah
//
//  Created by Haaris Iqubal on 15.12.23.
//

import Foundation
import UserNotifications

enum AuthorizationStatus {
    case notDetermined
    case denied
    case authorized
    case provisional
    #if !os(macOS) && !os(watchOS)
    case ephemeral
    #endif
    case unknown
}

@MainActor
class NotificationManager: NSObject, ObservableObject {
    
    static let shared = NotificationManager()

    private let notificationManager = UNUserNotificationCenter.current()
    @Published var isNotificationEnabled: Bool = false
    
    // Initialize authorizationStatus with a default value
    private var authorizationStatus: AuthorizationStatus = .notDetermined {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.isNotificationEnabled = self?.authorizationStatus == .authorized
            }
            
        }
    }

    private override init() {
        super.init()
        notificationManager.delegate = self
        requestNotification {[weak self] granted in
            print("self.notificationManager.isNotificationEnabled", granted)
            DispatchQueue.main.async { [weak self] in
                self?.isNotificationEnabled = granted
            }
           
        }
        getNotificationSetting()
    }

    func requestNotification(completion: @escaping (Bool) -> Void) {
            notificationManager.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                self.updateAuthorizationStatus(granted: granted)
                completion(granted)
            }
        }
    
    func getNotificationSetting() {
        notificationManager.getNotificationSettings {[weak self] setting in
            self?.updateAuthorizationStatus(status: setting.authorizationStatus)
        }
    }
    
    private func updateAuthorizationStatus(granted: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = granted ? .authorized : .denied
        }
    }
    
    private func updateAuthorizationStatus(status: UNAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = self.convertAuthorizationStatus(status)
        }
    }
    
    private func convertAuthorizationStatus(_ status: UNAuthorizationStatus) -> AuthorizationStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        #if !os(macOS) && !os(watchOS)
        case .ephemeral:
            return .ephemeral
        #endif
        default:
            return .unknown
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func notificationCenterDidChangeAuthorization(_ center: UNUserNotificationCenter) {
        center.getNotificationSettings {[weak self] setting in
            DispatchQueue.main.async {
                self?.updateAuthorizationStatus(status: setting.authorizationStatus)
            }
            
        }
    }
}

