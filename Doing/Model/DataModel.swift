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

    var list: [Item] = []

    var documentDirectory: URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.allDomainsMask)[0]
    }
    var dataFileUrl: URL {
        return documentDirectory.appendingPathComponent("TodoList").appendingPathExtension("json")
    }

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveChecklists),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
    }

    func sortCheckLists() {
        list.sort(by: { $0.name.lowercased().folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) < $1.name.lowercased().folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)})
    }



    @objc func saveChecklists() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self.list)
            try data.write(to: self.dataFileUrl, options: Data.WritingOptions.atomic)
        } catch {
            print(error)
        }
    }

    func loadChecklists() {
        if(FileManager.default.fileExists(atPath: (dataFileUrl.path))) {
            do {
                let data = try Data(contentsOf: self.dataFileUrl)
                let decoder = JSONDecoder()
                self.list = try decoder.decode([Item].self, from: data)
            } catch {
                print(error)
            }
        }
    }

}
