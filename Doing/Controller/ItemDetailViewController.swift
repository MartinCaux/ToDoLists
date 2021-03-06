//
//  ItemDetailViewController.swift
//  Doing
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailViewController: UITableViewController {

    let dataModel = DataModel.sharedInstance
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemDescription: UITextField!
    @IBOutlet weak var itemCreationTime: UILabel!
    @IBOutlet weak var itemModificationTime: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var noImageSelectedLabel: UILabel!
    @IBOutlet weak var imagePickerCell: UITableViewCell!
    
    var delegate: ItemDetailViewControllerDelegate?
    
    var itemToEdit: Item?
    var itemToEditCategory: Category?
    var selectedCategory: Category?
    
    override func viewDidLoad() {
        itemName.becomeFirstResponder()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        itemImage.isUserInteractionEnabled = true
        itemImage.addGestureRecognizer(tapGestureRecognizer)
        imagePickerCell.bringSubviewToFront(noImageSelectedLabel);
        imagePickerCell.sendSubviewToBack(itemImage)
        noImageSelectedLabel.layer.zPosition = 1;
        
        doneButton.isEnabled = false
        if(itemToEdit != nil) {
            navigationController?.title = "Edit Item"
            itemName.text = itemToEdit!.itemName
            itemDescription.text = itemToEdit!.itemDescription
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy 'at' hh:mm a"
            itemCreationTime.text = dateFormatter.string(from: itemToEdit!.creationTime!)
            if(itemToEdit!.modificationTime != nil) {
                itemModificationTime.text = dateFormatter.string(from: itemToEdit!.modificationTime!)
            }
            selectedCategory = itemToEditCategory!
            categoryLabel.text = selectedCategory?.categoryName
            itemImage.image = UIImage(data: (itemToEdit?.image!)!)
            itemImage.contentMode = .scaleToFill
            noImageSelectedLabel.isHidden = true
        } else {
            navigationController?.title = "Add Item"
            categoryLabel.text = "No Category Selected"
        }
        if(itemImage.image != nil) {
            noImageSelectedLabel.isHidden = true
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
            itemToEdit?.setValue(itemName.text, forKey: "itemName")
            itemToEdit?.setValue(itemDescription.text, forKey: "itemDescription")
            itemToEdit?.setValue(Date(), forKey: "modificationTime")
            itemToEdit?.setValue(itemImage.image?.pngData(), forKey: "image")
//            itemToEdit!.category = selectedCategory!
            if selectedCategory !== itemToEditCategory {
                itemToEdit?.setValue(selectedCategory, forKey: "Category")
                delegate!.listDetailViewController(self, didFinishEditingItem: itemToEdit!, fromCategory: itemToEditCategory!, toCategory: selectedCategory!)
            } else {
                delegate!.listDetailViewController(self, didFinishEditingItem: itemToEdit!)
            }
            dataModel.save()
        } else {
            let item = dataModel.insertItem(itemName: itemName.text!, itemDescription: itemDescription.text!, image: itemImage.image!, category: selectedCategory!)
            delegate!.listDetailViewController(self, didFinishAddingItem: item, forCategory: selectedCategory!)
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
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        // Your action
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
                doneButton!.isEnabled = (!newString!.isEmpty && newString! != itemToEdit!.itemName) || (itemDescription.text! != itemToEdit!.itemDescription) || (selectedCategory?.categoryName != itemToEdit!.category?.categoryName) || (itemImage.image?.pngData() != itemToEdit?.image)
            } else {
                doneButton!.isEnabled = !newString!.isEmpty && selectedCategory != nil && itemImage.image != nil
            }
        } else if textField == itemDescription {
            if itemToEdit != nil {
                doneButton!.isEnabled = (!itemName.text!.isEmpty && itemName.text! != itemToEdit!.itemName) || (newString! != itemToEdit!.itemDescription) || (selectedCategory?.categoryName != itemToEdit!.category?.categoryName) || (itemImage.image?.pngData() != itemToEdit?.image)
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
        categoryLabel.text = selectedCategory!.categoryName
        if itemToEdit != nil {
            doneButton!.isEnabled = (!itemName.text!.isEmpty && itemName.text! != itemToEdit!.itemName) || (itemDescription.text! != itemToEdit!.itemDescription) || (selectedCategory?.categoryName != itemToEdit!.category?.categoryName) || (itemImage.image?.pngData() != itemToEdit?.image)
        } else {
            self.doneButton!.isEnabled = !itemName.text!.isEmpty && selectedCategory != nil && itemImage.image != nil
        }
        tableView.reloadRows(at: [NSIndexPath(row: 0, section: 1) as IndexPath], with: .none)
        controller.dismiss(animated: false, completion: nil)
    }
}

extension ItemDetailViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            itemImage.contentMode = .scaleToFill
            noImageSelectedLabel.isHidden = true
            itemImage.image = image
            if itemToEdit != nil {
                doneButton!.isEnabled = (!itemName.text!.isEmpty && itemName.text! != itemToEdit!.itemName) || (itemDescription.text! != itemToEdit!.itemDescription) || (selectedCategory?.categoryName != itemToEdit!.category?.categoryName) || (itemImage.image?.pngData() != itemToEdit?.image)
            } else {
                self.doneButton!.isEnabled = !itemName.text!.isEmpty && selectedCategory != nil && itemImage.image != nil
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
