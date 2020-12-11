//
//  Networking.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 20/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import UIKit

final class Networking {

    func loadItems(completion: @escaping ([Item]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            let items = (0..<10).map({ (index) in
                Item(name: "Item \(index)")
            })
            completion(items)
        }
    }

    func loadImages(for item: Item, completion: @escaping ([UIImage]) -> Void) {
        let numberOfImages = Int.random(in: 5...10)

        let images = Array(1..<numberOfImages).shuffled().map { (index) -> UIImage in
            return UIImage(named: "image_\(index)")!
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            completion(images)
        }
    }
}
