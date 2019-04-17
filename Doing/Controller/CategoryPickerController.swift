//
//  CategoryPickerController.swift
//  Doing
//
//  Created by lpiem on 18/03/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import UIKit

class CategoryPickerController: UITableViewController {
        
    var delegate: CategoryPickerControllerDelegate?
    
    var dataModel = DataModel.sharedInstance
    
    var okAction: UIAlertAction?
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func addCategory(_ sender: Any) {
        let alertDialog = UIAlertController(title: "Add Category", message: "Enter the name for the category", preferredStyle: .alert)
        
        alertDialog.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.delegate = self
        }
        
        okAction = UIAlertAction(title: "Add", style: .default) {
            
            (action) in
            if (alertDialog.textFields?[0].text != "") {
                let category = self.dataModel.insertCategory(categoryName: alertDialog.textFields![0].text!)
                self.dataModel.categoryList.append(category)
                self.dataModel.selectedCategoryList.append(category)
                self.tableView.insertRows(at: [NSIndexPath(row: self.dataModel.categoryList.count - 1, section: 0) as IndexPath], with: .none)
            }
        }
        
        okAction!.isEnabled = false
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertDialog.addAction(okAction!)
        alertDialog.addAction(cancelAction)
        
        present(alertDialog, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.categoryList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryItem", for: indexPath)
        configureText(for: cell, withCategory: dataModel.categoryList[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.categoryPickerViewController(self, didFinishPickingCategory: dataModel.categoryList[indexPath.row])
    }
    
    func configureText(for cell: UITableViewCell, withCategory category: Category) {
        cell.textLabel!.text = category.categoryName
    }
    
}

protocol CategoryPickerControllerDelegate: class {
    func categoryPickerViewController(_ controller: CategoryPickerController, didFinishPickingCategory category: Category)
}

extension CategoryPickerController:UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        if(!newString!.isEmpty) {
            okAction!.isEnabled = true
        } else {
            okAction!.isEnabled = false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return (!(textField.text?.isEmpty)!)
    }
}
