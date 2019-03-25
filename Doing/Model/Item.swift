//
//  Item.swift
//  Doing
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import Foundation
import UIKit

class Item: Codable {
    var name: String
    var description: String
    var imageURLs: [String]
    var category: Category
    var creationTime: Date
    var modificationTime: Date?
    var checked: Bool

    init(name: String, description: String = "", checked: Bool = false, imageURLs: [String] = [], category: Category, creationTime: Date = Date(), modificationTime: Date? = nil) {
        self.name = name
        self.description = description
        self.imageURLs = imageURLs
        self.category = category
        self.creationTime = creationTime
        self.modificationTime = modificationTime
        self.checked = checked
    }

    func toggleChecked() {
        self.checked = !self.checked
    }

}

extension Item: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let item = Item(name: self.name, description: self.description, checked: self.checked, imageURLs: self.imageURLs, category: self.category, creationTime: self.creationTime, modificationTime: self.modificationTime)
        return item
    }   
}
