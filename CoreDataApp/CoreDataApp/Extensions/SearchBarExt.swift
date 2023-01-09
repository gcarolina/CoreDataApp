//  SearchBarExt.swift
//  CoreDataApp
//  Created by Carolina on 10.01.23.

import UIKit
import CoreData

extension ItemsTVController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            loadItems()
            searchBar.resignFirstResponder() // завершение ввода
        } else {
            let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
            let searchPredicate = NSPredicate(format: "title CONTAINS %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadItems(with: request, predicate: searchPredicate)
        }
    }
}
