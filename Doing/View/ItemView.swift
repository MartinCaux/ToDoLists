//
//  ItemView.swift
//  Doing
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import Foundation

class ItemView: Codable {
    var item: Item
    var checked: Bool
    
    init(item: Item, checked: Bool = false) {
        self.item = item
        self.checked = checked
    }
    
    func toggleChecked() {
        self.checked = !self.checked
    }
}
