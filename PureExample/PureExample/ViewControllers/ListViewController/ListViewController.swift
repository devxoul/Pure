//
//  ListViewController.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 19/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import UIKit
import Pure

final class ListViewController: UIViewController {

    // MARK: - Properties
    
    var networking: Networking!
    var notificationsService: RemoteNotificationService!
    var detailViewControllerFactory: ((Item) -> DetailViewController)!
    var items: [Item] = []

    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.requestAuthorization()
        self.loadItems()
    }

    // MARK: - Private Helpers

    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(UINib(nibName: "ItemCell", bundle: .main), forCellReuseIdentifier: "ItemCell")
    }

    private func requestAuthorization() {
        self.notificationsService.requestAuthorization { (result) in
            switch result {
            case .success(let granted):
                print("Notifications granted: \(granted)")
            case .failure(let error):
                print("Notifications authorization error: \(error)")
            }
        }
    }

    private func loadItems() {
        self.networking.loadItems { (items) in
            self.items = items
            self.tableView.reloadData()
        }
    }
    
    private func presentItemDetail(_ selectedItem: Item) {
        let detailViewController = self.detailViewControllerFactory(selectedItem)
        self.present(detailViewController, animated: true)
    }
}

// MARK: - UITableViewDelegate -

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        self.presentItemDetail(item)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource -

extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell else {
            return UITableViewCell()
        }
        let item = self.items[indexPath.row]
        cell.label?.text = item.name
        return cell
    }
}

// MARK: - Factory -

extension ListViewController {

    static let factory: (
        Networking,
        RemoteNotificationService,
        @escaping (Item) -> DetailViewController
        ) -> ListViewController = {
            (networking, notificationsService, detailViewControllerFactory) in
            let listViewController = ListViewController.loadFromStoryboard()
            listViewController.networking = networking
            listViewController.notificationsService = notificationsService
            listViewController.detailViewControllerFactory = detailViewControllerFactory
            return listViewController
    }
}

// MARK: - StoryboardLoadable -

extension ListViewController: StoryboardLoadable {}
