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
    
    init(name: String, imageURL: String? = "") {
        self.name = name
        self.imageURL = imageURL
    }
}
