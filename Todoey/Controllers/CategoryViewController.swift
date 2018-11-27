//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Rogelio Bernal on 11/27/18.
//  Copyright © 2018 Rogelio Bernal. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //what will happen once the user clicks the Add button on our alert
            
            let category = Category(context: self.context)
            category.name = textField.text!
            //append new items
            self.categoryArray.append(category)
            
            self.saveCategory()
        }
        
        alert.addTextField {(alertTextField) in //add the textField
            alertTextField.placeholder = "Create new category"
            textField = alertTextField //pass the data of alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    //eject performSegue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destivacionVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destivacionVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategory(){
        do{
            try context.save()
        }catch{
            print("error saving data \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //first with external parameter and request internal
    // "=" default value
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        //let request : NSFetchRequest<Item> = Item.fetchRequest() //request to data
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
}
