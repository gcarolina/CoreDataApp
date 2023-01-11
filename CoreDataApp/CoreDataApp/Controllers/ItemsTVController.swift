//  ItemsTVController.swift
//  CoreDataApp
//  Created by Carolina on 9.01.23.

import UIKit
import CoreData

class ItemsTVController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemsArray: [ItemModel] = []
    
    var selectedCategory: CategoryModel? {
        didSet {
            self.title = selectedCategory?.name
            getData()
        }
    }
    
    @IBAction func addNewItemAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new task", message: "", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Please enter your new task"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let texField = alert.textFields?.first,
               let text = texField.text,
               text != "",
               let self = self {
                let newItem = ItemModel(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                
                self.itemsArray.append(newItem)
                self.saveItems()
                self.tableView.insertRows(at: [IndexPath(row: self.itemsArray.count - 1, section: 0)], with: .automatic)
            }
        }
        cancel.setValue(UIColor.init(red: 60, green: 38, blue: 84), forKey: "titleTextColor")
        addAction.setValue(UIColor.init(red: 60, green: 38, blue: 84), forKey: "titleTextColor")
        
        alert.addAction(cancel)
        alert.addAction(addAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = itemsArray[indexPath.row].title
        cell.accessoryType = itemsArray[indexPath.row].done ? .checkmark : .none
        return cell
    }

    // MARK: - Table view delegate
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let categoryName = selectedCategory?.name, let itemName = itemsArray[indexPath.row].title {
                let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
                
                // Вариант с 2-мя предикатами, чтобы при удалении itemName в определенной категории не удалялись в других категориях данные по такому же имени
                let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
                let itemPredicate = NSPredicate(format: "title MATCHES %@", itemName)
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, itemPredicate])
                
                
                if let results = try? context.fetch(request) {
                    for object in results {
                        context.delete(object)
                    }
                    itemsArray.remove(at: indexPath.row)
                    saveItems()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // чтобы убрать выделение
        itemsArray[indexPath.row].done.toggle()
        self.saveItems()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    // MARK: - Core Data
    
    private func getData() {
        loadItems()
    }
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error save context")
        }
    }
        
    func loadItems(with request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest(),
                           predicate: NSPredicate? = nil) {
        guard let name = selectedCategory?.name else {
            return
        }
        // второй вариант создания предиката
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
            
        if let predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }
            
        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("Error fetch context")
        }
        tableView.reloadData()
    }
}
