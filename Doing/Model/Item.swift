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
    var imageURLs: [String] = []
    var categories: [Category] = []
    var checked: Bool

    init(name: String, description: String = "", checked: Bool = false) {
        self.name = name
        self.description = description
        self.checked = checked
    }

    func toggleChecked() {
        self.checked = !self.checked
    }

}
