//
//  ItemDetailViewController.swift
//  Doing
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import UIKit

class ItemDetailViewController: UITableViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var itemName: UITextField!
    
    var delegate: ItemDetailViewControllerDelegate?
    
    var itemToEdit: Item?
    
    override func viewDidLoad() {
        itemName.becomeFirstResponder()
        doneButton.isEnabled = false
        if(itemToEdit != nil) {
            navigationController?.title = "Edit Item"
            itemName.text = itemToEdit!.name
        } else {
            navigationController?.title = "Add Item"            
        }
        super.viewDidLoad()

    }
    
    @IBAction func done(_ sender: Any) {
        if(itemToEdit != nil) {
            itemToEdit!.name = itemName.text!
            delegate!.listDetailViewController(self, didFinishEditingItem: itemToEdit!)
        } else {
            delegate!.listDetailViewController(self, didFinishAddingItem: Item(name: itemName.text!))
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate!.listDetailViewControllerDidCancel(self)
    }
    
}

protocol ItemDetailViewControllerDelegate {
    func listDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func listDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: Item)
    func listDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: Item)
}

extension ItemDetailViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        doneButton!.isEnabled = !newString!.isEmpty
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return !(textField.text?.isEmpty)!
    }
}
