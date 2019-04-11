//
//  DataModel.swift
//  CheckLists
//
//  Created by lpiem on 21/02/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import Foundation
import NotificationCenter
import CoreData
import Firebase

class DataModel {
    static let sharedInstance = DataModel()

    let coreDataManager = CoreDataManager.shared()
    
    var categoryList: [Category] = []
    var selectedCategoryList: [Category] = []
    var currentFilter : String = ""
    var allCategoriesSelected: Bool = true

    var documentDirectory: URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask)[0]
    }
    var categoryListFileUrl: URL {
        return documentDirectory.appendingPathComponent("categoryList").appendingPathExtension("json")
    }
    
    var ref: DatabaseReference!

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(save),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        FirebaseApp.configure()
        ref = Database.database().reference()
    }

    
    func isAnyCategorySelected() -> Bool {
        for category: Category in categoryList {
            if(category.selected) {
                return true
            }
        }
        return false
    }
    
    @objc func save() {
        do {
            try coreDataManager.managedContext?.save()
        } catch {
            print("error")
        }
    }
    
    
    func filterItems(filter: String = "") {
        currentFilter = filter
        loadSelectedCategoryList()
        let tempsSelectedCategoryList = selectedCategoryList
        selectedCategoryList.removeAll()
        if filter != "" {
            for category: Category in tempsSelectedCategoryList {
                let itemList = getFilteredItemsForCategory(category: category)
                if itemList.count > 0 {
                    selectedCategoryList.append(category)
                }
            }
        } else {
            for category: Category in tempsSelectedCategoryList {
                selectedCategoryList.append(category)
            }
        }
    }
    
    func loadSelectedCategoryList() {
        if(allCategoriesSelected) {
            selectedCategoryList = coreDataManager.loadCategories()
        } else {
            selectedCategoryList = coreDataManager.getSelectedCategories()
        }
    }
    
    func getFilteredItemsForCategory(category: Category) -> [Item]{
        return coreDataManager.getFilteredItems(filter: currentFilter, forCategory: category)
    }
    
    func loadCategorylist() {
        ref.child("core/items").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let imageSnap = snap.childSnapshot(forPath: "Photo")
                let dict = imageSnap.value as! [String: Any]
                let url = dict["image"] as! String
                print(url)
            }
        })
        categoryList = coreDataManager.loadCategories()
    }
    
    func insertItem(itemName: String, itemDescription: String, checked: Bool = false, creationTime: Date = Date(), modificationTime: Date? = nil, image: UIImage, category: Category) -> Item {
        //setValue("category": category, "itemName": itemName, "itemDescription": itemDescription, "creationTime": creationTime, "modificationTime": modificationTime, "image": image.pngData())
        let item = [
            "category": category.categoryName,
            "itemName": itemName,
            "itemDescription": itemDescription,
            "creationTime": creationTime.timeIntervalSince1970,
            "modificationTime": modificationTime?.timeIntervalSince1970 ?? nil
            ] as [String : Any]
        let newRef = ref.child("core/items").childByAutoId()
        newRef.setValue(item)
        let itemId = newRef.key
        return coreDataManager.insertItem(itemId: itemId!, itemName: itemName, itemDescription: itemDescription, checked: checked, creationTime: creationTime, modificationTime: modificationTime, image: image, category: category)
    }
    
    func insertCategory(categoryName: String, selected: Bool = false) -> Category {
        let category = [
            "category": categoryName,
            "selected": selected
            ] as [String : Any]
        let newRef = ref.child("core/categories").childByAutoId()
        newRef.setValue(category)
        let categoryId = newRef.key
        return coreDataManager.insertCategory(categoryId: categoryId!, categoryName: categoryName, selected: selected)
    }
    
    func deleteItem(item: Item) {
        ref.child("core/items/\(item.id!)").removeValue()
        coreDataManager.deleteItem(item: item)
    }
    
    func deleteCategory(category: Category) {
        ref.child("core/categories/\(category.id!)").removeValue()
        coreDataManager.deleteCategory(category: category)
    }
    
}
