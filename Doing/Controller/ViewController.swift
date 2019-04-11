//  ViewController.swift
//
//  Doing
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let dataModel = DataModel.sharedInstance
    var okAction: UIAlertAction?

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var noResultCell: UITableViewCell!
    
    
    


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataModel.loadCategorylist()
        dataModel.allCategoriesSelected = !dataModel.isAnyCategorySelected()
        dataModel.loadSelectedCategoryList()
//        dataModel.loadChecklists()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBarHeightConstraint.constant = 0
        searchBar.isHidden = true
        searchBar.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func search(_ sender: Any) {
        navigationController?.isNavigationBarHidden = true
        searchBar.isHidden = false
        searchBarHeightConstraint.constant = 44
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addItem") {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! ItemDetailViewController
            destVC.delegate = self
        } else if (segue.identifier == "editItem") {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! ItemDetailViewController
            destVC.delegate = self
            let indexOfSelectedCell = tableView.indexPath(for: (sender as! UITableViewCell))
            let itemList = dataModel.getFilteredItemsForCategory(category: dataModel.selectedCategoryList[indexOfSelectedCell!.section])
            destVC.itemToEdit = itemList[indexOfSelectedCell!.row]
            destVC.itemToEditCategory = dataModel.selectedCategoryList[indexOfSelectedCell!.section]
        } else if (segue.identifier == "selectCategory") {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! CategoriesViewController
            destVC.delegate = self
        }
    }
}

extension ViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel.selectedCategoryList.count > 0 ? dataModel.selectedCategoryList.count : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataModel.selectedCategoryList.count > 0 ? dataModel.selectedCategoryList[section].categoryName : ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemList = dataModel.getFilteredItemsForCategory(category: dataModel.selectedCategoryList[section])
        return dataModel.selectedCategoryList.count > 0 ? itemList.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataModel.selectedCategoryList.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")!
            let itemList = dataModel.getFilteredItemsForCategory(category: dataModel.selectedCategoryList[indexPath.section])
            cell.textLabel?.text = itemList[indexPath.row].itemName
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy 'at' hh:mm a"
            cell.detailTextLabel?.text = itemList[indexPath.row].modificationTime != nil ? "updated on \(dateFormatter.string(from: itemList[indexPath.row].modificationTime!))" :
            "created on \(dateFormatter.string(from: itemList[indexPath.row].creationTime!))"
            cell.accessoryType = itemList[indexPath.row].checked ? .checkmark : .none
            return cell
        } else {
            return noResultCell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataModel.selectedCategoryList.count > 0 {
            let itemList = dataModel.getFilteredItemsForCategory(category: dataModel.selectedCategoryList[indexPath.section])
            itemList[indexPath.row].toggleChecked()
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if dataModel.selectedCategoryList.count > 0 {
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                let itemList = self.dataModel.getFilteredItemsForCategory(category: self.dataModel.selectedCategoryList[indexPath.section])
                self.dataModel.deleteItem(item: itemList[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                //self.dataModel.sortCheckLists()
            }
            let favorite = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
                self.performSegue(withIdentifier: "editItem", sender: tableView.cellForRow(at: indexPath))
            }
            favorite.backgroundColor = .orange
            return [delete, favorite]
        } else {
            return []
        }
    }


}


extension ViewController:ItemDetailViewControllerDelegate {
    
    func listDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        controller.dismiss(animated: true)
    }

    func listDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: Item, forCategory category: Category) {
        controller.dismiss(animated: true)
        //dataModel.sortCheckLists()
        //dataModel.filter()
        tableView.reloadData()
    }

    func listDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: Item) {
        controller.dismiss(animated: true)
        
        //dataModel.sortCheckLists()
        //dataModel.filter()
        tableView.reloadData()
    }
    
    func listDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: Item, fromCategory oldCategory: Category, toCategory newCategory: Category) {
        controller.dismiss(animated: true)
        
        //dataModel.sortCheckLists()
        //dataModel.filter()
        tableView.reloadData()
    }
}

extension ViewController:CategoriesViewControllerDelegate {
    func categoriesViewControllerDidFinishFiltering(controller: UITableViewController) {
        controller.dismiss(animated: true, completion: nil)
        dataModel.loadSelectedCategoryList()
        dataModel.loadCategorylist()
        tableView.reloadData()
    }
    
    
}

extension ViewController:UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //dataModel.initAllFilteredItemList()
        //dataModel.filter()
        navigationController?.isNavigationBarHidden = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.isHidden = true
        searchBar.showsCancelButton = false
        searchBarHeightConstraint.constant = 0
        dataModel.loadCategorylist()
        tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataModel.filterItems(filter: searchText)
        tableView.reloadData()
    }
    
}
