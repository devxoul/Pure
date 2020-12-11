//
//  RemoteNotificationService.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 20/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import Foundation
import UserNotifications

final class RemoteNotificationService: NSObject {
    
    private let notificationCenter: UNUserNotificationCenter
    
    init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
        super.init()
        notificationCenter.delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Result<Bool, Error>) -> Void) {
        notificationCenter.requestAuthorization(
            options: [.alert, .sound],
            completionHandler: { (granted, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(granted))
                }
        })
    }
}

extension RemoteNotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("did receive notification \(response.notification.request.content.userInfo)")
        completionHandler()
    }
    
    // When the app in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }
}
