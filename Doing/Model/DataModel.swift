//
//  DataModel.swift
//  CheckLists
//
//  Created by lpiem on 21/02/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import Foundation
import NotificationCenter

class DataModel {
    static let sharedInstance = DataModel()

    var itemList: [Item] = []
    var filteredItemList: [Item] = []
    var categoryList: [Category] = []
    var allCategoriesSelected: Bool = true

    var documentDirectory: URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask)[0]
    }
    var itemListFileUrl: URL {
        return documentDirectory.appendingPathComponent("itemList").appendingPathExtension("json")
    }
    var categoryListFileUrl: URL {
        return documentDirectory.appendingPathComponent("categoryList").appendingPathExtension("json")
    }

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveLists),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
    }

    func sortCheckLists() {
        itemList.sort(by: { $0.name.lowercased().folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) < $1.name.lowercased().folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)})
    }



    @objc func saveChecklists() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self.itemList)
            try data.write(to: self.itemListFileUrl, options: Data.WritingOptions.atomic)
        } catch {
            print(error)
        }
    }
    
    func loadChecklists() {
        if(FileManager.default.fileExists(atPath: (itemListFileUrl.path))) {
            do {
                let data = try Data(contentsOf: self.itemListFileUrl)
                let decoder = JSONDecoder()
                self.itemList = try decoder.decode([Item].self, from: data)
                self.filteredItemList = itemList
            } catch {
                print(error)
            }
        }
        filter()
    }
    
    func isAnyCategorySelected() -> Bool {
        for category: Category in categoryList {
            if(category.selected) {
                return true
            }
        }
        return false
    }
    
    func filter() {
        filteredItemList.removeAll()
        allCategoriesSelected = !isAnyCategorySelected()
        if(!allCategoriesSelected) {
            for category: Category in categoryList {
                if(category.selected) {
                    for item: Item in itemList {
                        if(item.category.name == category.name) {
                            filteredItemList.append(item)
                        }
                    }
                }
            }
        } else {
            filteredItemList.append(contentsOf: itemList)
        }
    }

    @objc func saveCategorylist() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self.categoryList)
            try data.write(to: self.categoryListFileUrl, options: Data.WritingOptions.atomic)
        } catch {
            print(error)
        }
    }
    
    @objc func saveLists() {
        saveChecklists()
        saveCategorylist()
    }

    
    func loadCategorylist() {
        if(FileManager.default.fileExists(atPath: (categoryListFileUrl.path))) {
            do {
                let data = try Data(contentsOf: self.categoryListFileUrl)
                let decoder = JSONDecoder()
                self.categoryList = try decoder.decode([Category].self, from: data)
            } catch {
                print(error)
            }
        }
        else {
            categoryList.append(Category(name: "Films"))
            categoryList.append(Category(name: "Jobs"))
            categoryList.append(Category(name: "Apps"))
        }
    }
}
