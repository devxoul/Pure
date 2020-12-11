//
//  AppDependency.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 20/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import UIKit
import UserNotifications
import Pure

struct AppDependency {
    let networking: Networking
    let remoteNotificationService: RemoteNotificationService
    let listViewControllerFactory: ListViewController.Factory
}

extension AppDependency {
    
    static func resolve() -> AppDependency {
        let networking = Networking()
        let remoteNotificationService = RemoteNotificationService(
            notificationCenter: UNUserNotificationCenter.current()
        )
        
        return AppDependency(
            networking: networking,
            remoteNotificationService: remoteNotificationService,
            listViewControllerFactory: ListViewController.Factory(
                dependency: .init(
                    networking: networking,
                    notificationsService: remoteNotificationService,
                    factory: DetailViewController.Factory(
                        dependency: .init(
                            networking: networking,
                            imageCellConfigurator: ImageCell.Configurator()
                        )
                    )
                )
            )
        )
    }
}

// MARK: - Pure Factory Module -

// MARK: - ListViewController -

extension ListViewController: FactoryModule {
    struct Dependency {
        let networking: Networking
        let notificationsService: RemoteNotificationService
        let factory: DetailViewController.Factory
    }
}

extension Factory where Module == ListViewController {

    func create() -> ListViewController {
        let module = ListViewController.loadFromStoryboard()
        module.networking = dependency.networking
        module.notificationsService = dependency.notificationsService
        module.factory = dependency.factory
        return module
    }
}

// MARK: - DetailViewController -

extension DetailViewController: FactoryModule {
    struct Dependency {
        let networking: Networking
        let imageCellConfigurator: ImageCell.Configurator
    }

    struct Payload {
        let selectedItem: Item
    }
}

extension Factory where Module == DetailViewController {

    func create(payload: DetailViewController.Payload) -> DetailViewController {
        let vc = DetailViewController.loadFromStoryboard()
        vc.networking = dependency.networking
        vc.imageCellConfigurator = dependency.imageCellConfigurator
        vc.item = payload.selectedItem
        return vc
    }
}

// MARK: - ImageCell -

extension ImageCell: ConfiguratorModule {
    struct Payload {
        let image: UIImage
    }

    func configure(dependency: Void, payload: ImageCell.Payload) {
        self.imageView.image = payload.image
    }
}
