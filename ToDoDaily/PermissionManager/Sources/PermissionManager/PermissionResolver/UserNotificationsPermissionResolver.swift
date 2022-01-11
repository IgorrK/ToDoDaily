//
//  UserNotificationsPermissionResolver.swift
//  
//
//  Created by Igor Kulik on 11.01.2022.
//

import Foundation
import UserNotifications

struct UserNotificationsPermissionResolver: PermissionResolver {
    func resolvePermission(_ callback: @escaping Callback<PermissionManager.PermisionStatus>) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                callback(.authorized)
            } else {
                callback(.denied)
            }
        }
    }
}
