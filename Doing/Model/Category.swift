//
//  Category.swift
//  Doing
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import Foundation
import UIKit

class Category: Codable {
    var name: String
    var imageURL: String?
    var selected: Bool
    var items: [Item]
    var filteredItems: [Item]

    init(name: String, imageURL: String? = "", selected: Bool = false, items: [Item] = [], filteredItems: [Item] = []) {
        self.name = name
        self.imageURL = imageURL
        self.selected = selected
        self.items = items
        self.filteredItems = filteredItems
    }

    func toggleSelected() {
        self.selected = !self.selected
    }
    
    func initFilteredItems() {
        self.filteredItems = items
    }
}

extension Category: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let category = Category(name: self.name, imageURL: self.imageURL, selected: self.selected, items: self.items, filteredItems: self.filteredItems)
        return category
    }
}
