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
    
    init(name: String, description: String = "") {
        self.name = name
        self.description = description
    }
    
    
}
