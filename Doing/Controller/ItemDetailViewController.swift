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
    @IBOutlet weak var itemDescription: UITextField!
    @IBOutlet weak var itemCreationTime: UILabel!
    @IBOutlet weak var itemModificationTime: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var delegate: ItemDetailViewControllerDelegate?
    
    var itemToEdit: Item?
    var itemToEditCategory: Category?
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        itemName.becomeFirstResponder()
        doneButton.isEnabled = false
        if(itemToEdit != nil) {
            navigationController?.title = "Edit Item"
            itemName.text = itemToEdit!.name
            itemDescription.text = itemToEdit!.description
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy 'at' hh:mm a"
            itemCreationTime.text = dateFormatter.string(from: itemToEdit!.creationTime)
            if(itemToEdit!.modificationTime != nil) {
                itemModificationTime.text = dateFormatter.string(from: itemToEdit!.modificationTime!)
            }
            selectedCategory = itemToEditCategory!
            categoryLabel.text = selectedCategory?.name
        } else {
            navigationController?.title = "Add Item"
            categoryLabel.text = "No Category Selected"
        }
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "pickCategory") {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! CategoryPickerController
            destVC.delegate = self
        }
    }
    
    
    @IBAction func done(_ sender: Any) {
        if(itemToEdit != nil) {
            itemToEdit!.name = itemName.text!
            itemToEdit!.description = itemDescription.text!
            itemToEdit!.modificationTime = Date()
//            itemToEdit!.category = selectedCategory!
            if selectedCategory !== itemToEditCategory {
                delegate!.listDetailViewController(self, didFinishEditingItem: itemToEdit!, fromCategory: itemToEditCategory!, toCategory: selectedCategory!)
            } else {
                delegate!.listDetailViewController(self, didFinishEditingItem: itemToEdit!)
            }
        } else {
            delegate!.listDetailViewController(self, didFinishAddingItem: Item(name: itemName.text!, description: itemDescription.text!), forCategory: selectedCategory!)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate!.listDetailViewControllerDidCancel(self)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1) {
            itemName.resignFirstResponder()
            tableView.deselectRow(at: indexPath, animated: true)
            //performSegue(withIdentifier: "pickCategory", sender: tableView.cellForRow(at: indexPath))
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
}

protocol ItemDetailViewControllerDelegate {
    func listDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func listDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: Item, forCategory category: Category)
    func listDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: Item)
    func listDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: Item, fromCategory oldCategory: Category, toCategory newCategory: Category)
}

extension ItemDetailViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        
        if textField == itemName {
            if itemToEdit != nil {
                doneButton!.isEnabled = (!newString!.isEmpty && newString! != itemToEdit!.name) || (itemDescription.text! != itemToEdit!.description) || selectedCategory !== itemToEditCategory
            } else {
                doneButton!.isEnabled = !newString!.isEmpty && selectedCategory != nil
            }
        } else if textField == itemDescription {
            if itemToEdit != nil {
                doneButton!.isEnabled = (!itemName.text!.isEmpty && itemName.text! != itemToEdit!.name) || (newString! != itemToEdit!.description) || selectedCategory !== itemToEditCategory
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return !(textField.text?.isEmpty)!
    }
}

extension ItemDetailViewController:CategoryPickerControllerDelegate {
    func categoryPickerViewController(_ controller: CategoryPickerController, didFinishPickingCategory category: Category) {
        selectedCategory = category
        categoryLabel.text = selectedCategory!.name
        if itemToEdit != nil {
            doneButton!.isEnabled = (!itemName.text!.isEmpty && itemName.text! != itemToEdit!.name) || (itemDescription.text! != itemToEdit!.description) || selectedCategory !== itemToEditCategory
        } else {
            self.doneButton!.isEnabled = !itemName.text!.isEmpty && selectedCategory != nil
        }
        tableView.reloadRows(at: [NSIndexPath(row: 0, section: 1) as IndexPath], with: .none)
        controller.dismiss(animated: false, completion: nil)
    }
}
