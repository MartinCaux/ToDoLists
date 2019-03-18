//
//  ViewController.swift
//  TestApp
//
//  Created by lpiem on 18/03/2019.
//  Copyright © 2019 Clément MERLET. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let newItem = Item(context: CoreDataManager.shared.persistentContainer.viewContext)
        CoreDataManager.shared.items.append(newItem)
        // Do any additional setup after loading the view, typically from a nib.
    }


    /*
 
 Recuperation du context = CoreDataManager.shared.peristentContainer.viewContext
 

 Instancier un element let newItem = Item(context: context)
 
 CoreDataManager.shared.peristentContainer.viewContext
 CoreDataManager.items.append(newItem)
 
 
 */
    
    
    
}

