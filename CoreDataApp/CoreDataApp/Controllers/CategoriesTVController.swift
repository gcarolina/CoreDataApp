//  CategoriesTVController.swift
//  CoreDataApp
//  Created by Carolina on 9.01.23.

import UIKit
import CoreData

class CategoriesTVController: UITableViewController {

    var categories = [CategoryModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        navigationController?.navigationBar.barTintColor = .init(red: 185, green: 118, blue: 166)
    }
    
    @IBAction func addNewCategory(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Category"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,
               let text = textField.text,
               text != "",
               let self = self {
                let newCategory = CategoryModel(context: self.context)
                newCategory.name = text
                self.categories.append(newCategory)
//                self.tableView.reloadData()
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .automatic)
                self.saveCategories()
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
        categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showItemsSegue", sender: nil)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
           let name = categories[indexPath.row].name {
            let request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
            // первый вариант создания предиката
            request.predicate = NSPredicate(format: "name==\(name)")

            if let categories = try? context.fetch(request) {
                for category in categories {
                    context.delete(category)
                }

                self.categories.remove(at: indexPath.row)
                saveCategories()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toDoListVC = segue.destination as? ItemsTVController,
           let indexPath = tableView.indexPathForSelectedRow {
            toDoListVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    // MARK: - CoreData
    
    private func getData() {
        loadCategories()
        tableView.reloadData()
    }
    
    private func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error save context: \(error)")
        }
    }
    
    private func loadCategories(with request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetch context")
        }
    }
}
