//
//  NotificationScheduler.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 28.01.2022.
//

import Foundation
import UserNotifications

struct NotificationScheduler {
    
    // MARK: - Properties
    
    private static let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Public methods
    
    static func scheduleNotification(for task: TaskPresentation) -> UUID? {
        guard let dueDate = task.dueDate else {
            return nil
        }
        let content = UNMutableNotificationContent()
        content.subtitle = task.text
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = UUID()
        
        let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request)
        
        return identifier
    }
    
    static func cancelNotification(id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
}
