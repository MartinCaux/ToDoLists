//
//  CoreDataManager.swift
//  Doing
//
//  Created by lpiem on 11/04/2019.
//  Copyright © 2019 Martin Caux. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    var managedContext: NSManagedObjectContext?
    
    private static var sharedNetworkManager: CoreDataManager = {
        let dataManager = CoreDataManager()
        
        // Configuration
        // ...
        
        return dataManager
    }()
    
    
    class func shared() -> CoreDataManager {
        return sharedNetworkManager
    }
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func insertItem(itemId: String, itemName: String, itemDescription: String, checked: Bool = false, creationTime: Date = Date(), modificationTime: Date? = nil, image: UIImage, category: Category) -> Item {
        let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedContext!)
        let item = NSManagedObject(entity: entity!, insertInto: managedContext!)
        item.setValue(itemId, forKey: "id")
        item.setValue(itemName, forKey: "itemName")
        item.setValue(itemDescription, forKey: "itemDescription")
        item.setValue(checked, forKey: "checked")
        item.setValue(creationTime, forKey: "creationTime")
        item.setValue(modificationTime, forKey: "modificationTime")
        item.setValue(image.pngData(), forKey: "image")
        item.setValue(category, forKey: "category")
        do {
            try managedContext!.save()
        } catch {
            print("error")
        }
        return item as! Item
    }
    
    func insertCategory(categoryId: String, categoryName: String, selected: Bool = false) -> Category {
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext!)
        let category = NSManagedObject(entity: entity!, insertInto: managedContext!)
        category.setValue(categoryId, forKey: "id")
        category.setValue(categoryName, forKey: "categoryName")
        category.setValue(selected, forKey: "selected")
        do {
            try managedContext!.save()
        } catch {
            print("error")
        }
        return category as! Category
    }
    
    func loadCategories() -> [Category] {
        return fetchRecordsForEntity("Category", inManagedObjectContext: managedContext!) as! [Category]
    }
    
    func deleteCategory(category: Category) {
        managedContext?.delete(category)
    }
    
    func deleteItem(item: Item) {
        managedContext?.delete(item)
    }
    
    func getSelectedCategories() -> [Category] {
        return fetchRecordsForEntity("Category", inManagedObjectContext: managedContext!, selected: true) as! [Category]
    }
    
    func getFilteredItems(filter: String, forCategory category: Category) -> [Item] {
        if(filter == "") {
            return fetchRecordsForEntity("Item", inManagedObjectContext: managedContext!, category: category) as! [Item]
        } else {
            return fetchRecordsForEntity("Item", inManagedObjectContext: managedContext!, filter: filter, category: category) as! [Item]
        }
    }
    
    func getLastInsertedItem() -> Item? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do {
            let allElementsCount = try managedContext!.count(for: request)
            request.fetchLimit = 1
            request.fetchOffset = allElementsCount - 1
            request.returnsObjectsAsFaults = false
            if let items:[Item] = executeFetchRequestT(request: request, managedObjectContext: managedContext!) {
                return items[0]
            } else {
                // should have an error condition, handle it appropriately
                assertionFailure("something bad happened")
            }
        } catch {
            print("error")
        }
        return nil
    }
    
    private func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext, selected: Bool = false, filter: String? = nil, category: Category? = nil) -> [NSManagedObject] {
        // Create Fetch Request
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        if(selected) {
            fetchRequest.predicate = NSPredicate(format: "selected == YES")
        }
        if(category != nil && filter != nil) {
            fetchRequest.predicate = NSPredicate(format: "itemName CONTAINS[cd] %@ AND category == %@", filter!, category!)
        } else if category != nil && filter == nil {
            fetchRequest.predicate = NSPredicate(format: "category == %@" , category!)
        }
        
        // Helpers
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        
        return result
    }
    
    func executeFetchRequestT<T:AnyObject>(request:NSFetchRequest<NSFetchRequestResult>, managedObjectContext:NSManagedObjectContext) -> [T]? {
        do {
            if let results:[AnyObject] = try managedObjectContext.fetch(request) as [AnyObject]? {
                if results.count > 0 {
                    if results[0] is T {
                        let casted:[T] = results as! [T]
                        return .some(casted)
                    }
                    
                    
                } else if 0 == results.count {
                    return [T]() // just return an empty array
                }
            }
        } catch {
            print("error")
        }
        
        return .none
    }
    
}
