//
//  NotificationManager.swift
//  NotificationApp
//
//  Created by Sok Pich on 4/17/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notifications permission granted")
            } else {
                print("❌ Notifications permission denied")
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hello from SwiftUI!"
        content.body = "This is a local notification sent from SwiftUI!"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "localNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error adding notification: \(error)")
            } else {
                print("📬 Notification scheduled!")
            }
        }
    }
    
    func scheduleMultipleNotifications() {
        for i in 1...3 {
            let content = UNMutableNotificationContent()
            content.title = "Notification \(i)"
            content.body = "This is notification #\(i)"
            content.sound = .default
            content.badge = NSNumber(value: i * 99)

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(5 * i), repeats: false)

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification \(i): \(error)")
                } else {
                    print("✅ Notification \(i) scheduled for \(5 * i) seconds later")
                }
            }
        }
    }

}
