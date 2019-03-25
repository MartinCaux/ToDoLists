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

    @IBOutlet weak var tableView: UITableView!

    var okAction: UIAlertAction?


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataModel.loadCategorylist()
        dataModel.loadChecklists()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
            destVC.itemToEdit = dataModel.filteredItemList[indexOfSelectedCell!.row]
        } else if (segue.identifier == "selectCategory") {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! CategoriesViewController
            destVC.delegate = self
        }
    }
}

extension ViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.filteredItemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")!
        cell.textLabel?.text = dataModel.filteredItemList[indexPath.row].name
        cell.accessoryType = dataModel.filteredItemList[indexPath.row].checked ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataModel.filteredItemList[indexPath.row].toggleChecked()
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            let itemToDelete = self.dataModel.filteredItemList[indexPath.row]
            let indexOfItemToDelete = self.dataModel.itemList.index(where: { (item) -> Bool in
                item.name == itemToDelete.name && item.category.name == itemToDelete.category.name
            })
            self.dataModel.itemList.remove(at: indexOfItemToDelete!)
            self.dataModel.filteredItemList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            self.dataModel.sortCheckLists()
        }
        let favorite = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.performSegue(withIdentifier: "editItem", sender: tableView.cellForRow(at: indexPath))
        }
        favorite.backgroundColor = .orange
        return [delete, favorite]
    }


}


extension ViewController:ItemDetailViewControllerDelegate {
    func listDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        controller.dismiss(animated: true)
    }

    func listDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: Item) {
        controller.dismiss(animated: true)
        dataModel.itemList.append(item)
        dataModel.sortCheckLists()
//        let indexOfNewItem = dataModel.itemList.index(where: {$0 === item})
        //        self.tableView.insertRows(at: [NSIndexPath(row: indexOfNewItem!, section: 0) as IndexPath], with: UITableView.RowAnimation.automatic)
        dataModel.filter()
        tableView.reloadData()
    }

    func listDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: Item) {
        controller.dismiss(animated: true)
//        let indexOfPreviousItem = dataModel.itemList.index(where: {$0 === item})
        dataModel.sortCheckLists()
//        let indexOfEditedItem = dataModel.itemList.index(where: {$0 === item})
//        dataModel.itemList.remove(at: indexOfPreviousItem!)
//        self.tableView.deleteRows(at: [NSIndexPath(row: indexOfPreviousItem!, section: 0) as IndexPath], with: UITableView.RowAnimation.fade)
//        dataModel.itemList.insert(item, at: indexOfEditedItem!)
//        self.tableView.insertRows(at: [NSIndexPath(row: indexOfEditedItem!, section: 0) as IndexPath], with: UITableView.RowAnimation.automatic)
        dataModel.filter()
        tableView.reloadData()
    }
}

extension ViewController:CategoriesViewControllerDelegate {
    func categoriesViewControllerDidFinishFiltering(controller: UITableViewController) {
        controller.dismiss(animated: true, completion: nil)
        dataModel.filter()
        tableView.reloadData()
    }
    
    
}
