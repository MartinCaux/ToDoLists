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
    var checked: Bool

    init(name: String, imageURL: String? = "", checked: Bool = false) {
        self.name = name
        self.imageURL = imageURL
        self.checked = checked
    }

    func toggleChecked() {
        self.checked = !self.checked
    }
}
