//
//  DetailViewController.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 20/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    // MARK: - Properties

    var networking: Networking!
    var item: Item!
    var imageCellConfigurator: ((ImageCell, UIImage) -> Void)?
    var images: [UIImage] = []

    // MARK: - IBOutlets

    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.loadImages()
    }

    // MARK: - Private helpers
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "ImageCell", bundle: .main), forCellWithReuseIdentifier: "ImageCell")

        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(200.0)
        )
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(200.0)
        )
        let item1 = NSCollectionLayoutItem(layoutSize: itemSize)
        let item2 = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item1, item2])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        self.collectionView.collectionViewLayout = layout
    }

    private func loadImages() {
        self.networking.loadImages(for: self.item, completion: { (images) in
            self.images = images
            self.collectionView.reloadData()
        })
    }
}

// MARK: - UICollectionViewDelegate -

extension DetailViewController: UICollectionViewDelegate {

}

// MARK: - UICollectionViewDataSource -

extension DetailViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        let image = self.images[indexPath.row]
        self.imageCellConfigurator?(cell, image)
        return cell
    }
}

// MARK: - Factory -
extension DetailViewController {

    static let factory: (
        Networking,
        @escaping (ImageCell, UIImage) -> Void
        ) -> (Item) -> DetailViewController = {
        (networking, imageCellConfigurator) in
        return { selectedItem in
            let detailViewController = DetailViewController.loadFromStoryboard()
            detailViewController.networking = networking
            detailViewController.item = selectedItem
            detailViewController.imageCellConfigurator = imageCellConfigurator
            return detailViewController
        }
    }
}

// MARK: - StoryboardLoadable -
extension DetailViewController: StoryboardLoadable {}
