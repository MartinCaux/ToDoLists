//
//  CategoriesViewController.swift
//  Doing
//
//  Created by lpiem on 18/03/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import UIKit

class CategoriesViewController: UITableViewController {

    let dataModel = DataModel.sharedInstance
    var tempCategoryList = DataModel.sharedInstance.categoryList.map{($0.copy() as! Category)}
    @IBOutlet weak var allCategoriesCell: UITableViewCell!
    @IBOutlet weak var addCategoryCell: UITableViewCell!
    
    var isAllSelected = true
    
    var delegate: CategoriesViewControllerDelegate?
    
    var okAction: UIAlertAction?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAllSelected = toggleAll()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReuseIdentifierCustomCell")
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        dataModel.categoryList = tempCategoryList
        delegate?.categoriesViewControllerDidFinishFiltering(controller: self)
    }
    
    @IBAction func addCategory(_ sender: Any?) {
        
        let alertDialog = UIAlertController(title: "Add Category", message: "Enter the name for the category", preferredStyle: .alert)
        
        alertDialog.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.delegate = self
        }
        
        okAction = UIAlertAction(title: "Add", style: .default) {
            
            (action) in
            if (alertDialog.textFields?[0].text != "") {
                let category = Category(name: alertDialog.textFields![0].text!)
                self.tempCategoryList.append(category)
                self.tableView.insertRows(at: [NSIndexPath(row: self.tempCategoryList.count - 1, section: 1) as IndexPath], with: .none)
            }
        }
        
        okAction!.isEnabled = false
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertDialog.addAction(okAction!)
        alertDialog.addAction(cancelAction)
        
        present(alertDialog, animated: true, completion: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseIdentifierCustomCell", for: indexPath)
            cell.textLabel?.text = tempCategoryList[indexPath.row].name
            cell.accessoryType = tempCategoryList[indexPath.row].selected ? .checkmark : .none
            return cell
        } else if indexPath.section == 0 {
            let cell = allCategoriesCell
            cell?.accessoryType = isAllSelected ? .checkmark : .none
            return cell!
        } else if indexPath.section == 2 {
            let cell = addCategoryCell
            cell?.selectionStyle = .none
            return cell!
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 44
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return tempCategoryList.count
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if(indexPath.section == 0 && indexPath.row == 0) {
            if(!isAllSelected) {
                isAllSelected = true
                dataModel.allCategoriesSelected = isAllSelected
                deselectAllRows()
                tableView.deselectRow(at: indexPath, animated: false)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        } else if(indexPath.section == 2) {
            addCategory(nil)
            tableView.deselectRow(at: indexPath, animated: false)
        } else if indexPath.section == 1 {
            toggleSelected(position: indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == 1 {
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 0))
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                self.deleteRow(indexPath: indexPath)
            }
            return [delete]
        } else {
            return []
        }
    }
    
    func deleteRow(indexPath: IndexPath) {
        let itemForCategory = itemList(itemList: dataModel.itemList, contains: tempCategoryList[indexPath.row])
        if itemForCategory.count == 0 {
            self.tempCategoryList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .none)
            if self.toggleAll() {
                tableView.reloadRows(at: [NSIndexPath(row: 0, section: 0) as IndexPath], with: .none)
            }
        } else {
            var message = "This category is used in : \n"
            var counter = 0
            for item: Item in itemForCategory {
                counter += 1
                if counter < 3 && counter < itemForCategory.count {
                    message += "\(item.name), "
                } else if counter == 3 || counter == itemForCategory.count {
                    message += "\(item.name)"
                    break
                }
            }
            message += "."
            
            let alertDialog = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            alertDialog.addAction(UIAlertAction(title: "Ok", style: .default))
            
            present(alertDialog, animated: true, completion: nil)
            
        }
    }
    
    func itemList(itemList: [Item], contains category: Category ) -> [Item] {
        var itemForCategory = [Item]()
        for item: Item in itemList {
            if item.category.name == category.name {
                itemForCategory.append(item)
            }
        }
        return itemForCategory
    }
    
    func deselectAllRows() {
        for index in 0 ... tempCategoryList.count - 1 {
            tempCategoryList[index].selected = false
        }
        tableView.reloadSections(IndexSet(integersIn: 1...1), with: .none)
    }
    
    
    func toggleSelected(position: Int) {
        tempCategoryList[position].toggleSelected()
        if toggleAll() != isAllSelected {
            isAllSelected = !isAllSelected
            dataModel.allCategoriesSelected = isAllSelected
            tableView.reloadRows(at: [NSIndexPath(row: 0, section: 0) as IndexPath], with: .none)
        }
    }
    
    func toggleAll() -> Bool {
        var isAllSelected = false
        var count = 0
        if(tempCategoryList.count > 0) {
            for index in 0 ... tempCategoryList.count - 1 {
                if(tempCategoryList[index].selected) {
                    count += 1
                }
            }
        }
        if(count > 0) {
            isAllSelected = false
        } else {
            isAllSelected = true
        }
        return isAllSelected
    }

}


protocol CategoriesViewControllerDelegate:class {
    func categoriesViewControllerDidFinishFiltering(controller: UITableViewController)
}

extension CategoriesViewController:UITextFieldDelegate {
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
