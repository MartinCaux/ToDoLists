//
//  CategoryView.swift
//  Doing
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import Foundation

class CategoryView: Codable {
    var category: Category
    var checked: Bool
    
    init(category: Category, checked: Bool = false) {
        self.category = category
        self.checked = checked
    }
    
    func toggleChecked() {
        self.checked = !self.checked
    }
}
