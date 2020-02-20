//
//  ImageCell.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 20/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!

    static let configurator: () -> (ImageCell, UIImage) -> Void = {
        return { cell, image in
            cell.imageView.image = image
        }
    }
}
