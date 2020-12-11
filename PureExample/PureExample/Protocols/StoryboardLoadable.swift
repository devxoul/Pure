//
//  StoryboardLoadable.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 19/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import UIKit

protocol StoryboardLoadable: class {
    static var storyboardName: String { get }
    static var controllerId: String { get }
}

extension StoryboardLoadable where Self: UIViewController {
    
    static var storyboardName: String {
        return String(describing: Self.self)
    }
    
    static var controllerId: String {
        return String(describing: Self.self)
    }
    
    static func loadFromStoryboard() -> Self {
        let bundle = Bundle(for: Self.self)
        let storyboard = UIStoryboard(name: Self.storyboardName, bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: Self.controllerId) as! Self
    }
}
