//
//  AppDependency.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 20/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import Foundation
import UserNotifications

struct AppDependency {
    let networking: Networking
    let remoteNotificationService: RemoteNotificationService
    let listViewControllerFactory: () -> ListViewController
}

extension AppDependency {
    
    static func resolve() -> AppDependency {
        let networking = Networking()
        let remoteNotificationService = RemoteNotificationService(
            notificationCenter: UNUserNotificationCenter.current()
        )

        let detailViewControllerFactory = DetailViewController.factory(
            networking,
            ImageCell.configurator()
        )
        
        return AppDependency(
            networking: networking,
            remoteNotificationService: remoteNotificationService,
            listViewControllerFactory: {
                return ListViewController.factory(
                    networking,
                    remoteNotificationService,
                    detailViewControllerFactory
                )
        })
    }
}
