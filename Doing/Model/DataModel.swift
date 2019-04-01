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

    var categoryList: [Category] = []
    var selectedCategoryList: [Category] = []
    var allCategoriesSelected: Bool = true

    var documentDirectory: URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask)[0]
    }
    var categoryListFileUrl: URL {
        return documentDirectory.appendingPathComponent("categoryList").appendingPathExtension("json")
    }

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveCategorylist),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
    }

    func sortCheckLists() {
        for category: Category in selectedCategoryList {
            category.items.sort(by: { $0.name.lowercased().folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) < $1.name.lowercased().folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)})
        }
        for category: Category in selectedCategoryList {
            category.filteredItems.sort(by: { $0.name.lowercased().folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) < $1.name.lowercased().folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)})
        }
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
        selectedCategoryList.removeAll()
        allCategoriesSelected = !isAnyCategorySelected()
        if(!allCategoriesSelected) {
            for category: Category in categoryList {
                if category.selected && category.filteredItems.count > 0 {
                    selectedCategoryList.append(category)
                }
            }
        } else {
            for category: Category in categoryList {
                if category.filteredItems.count > 0 {
                    selectedCategoryList.append(category)
                }
            }
        }
    }
    
    func filterItems(filter: String = "") {
        self.initAllFilteredItemList()
        self.filter()
        if filter != "" {
            for category: Category in selectedCategoryList {
                category.filteredItems.removeAll()
                for item: Item in category.items {
                    if item.name.range(of: filter, options: .caseInsensitive) != nil    {
                        category.filteredItems.append(item)
                    }
                }
            }
        } else {
            for category: Category in selectedCategoryList {
                category.filteredItems.removeAll()
                for item: Item in category.items {
                    category.filteredItems.append(item)
                }
            }
        }
        self.filter()
    }
    
    
    func initAllFilteredItemList() {
        for category: Category in categoryList {
            category.initFilteredItems()
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
    
    func loadCategorylist() {
        if(FileManager.default.fileExists(atPath: (categoryListFileUrl.path))) {
            do {
                let data = try Data(contentsOf: self.categoryListFileUrl)
                let decoder = JSONDecoder()
                self.categoryList = try decoder.decode([Category].self, from: data)
                initAllFilteredItemList()
                filter()
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
