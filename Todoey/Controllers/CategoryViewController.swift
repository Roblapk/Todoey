//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Rogelio Bernal on 11/27/18.
//  Copyright © 2018 Rogelio Bernal. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    
    var categoryArray : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : FlatWhite()] //at the begining
        loadCategories()
    }
    
    //MARK: - Add new categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //what will happen once the user clicks the Add button on our alert
            
            let category = Category() //CATEGORY DATA MODEL
            category.name = textField.text!
            category.color = UIColor.randomFlat.hexValue() //return random color on string
            //append new items
            
            //self.categoryArray.append(category) not needed because is auto-updating by realm
            
            self.save(category:category)
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
        return categoryArray?.count ?? 1 //If categories is not null, eject the first, if not 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) //say where is the cell row at (current index path)
        
        if let category = categoryArray?[indexPath.row]{
            cell.textLabel?.text = category.name //eject the first if is not null, then de second one
            cell.backgroundColor = UIColor(hexString: category.color)
            
            guard let categoryColor = UIColor(hexString: category.color) else{
                fatalError("error with category color")
            }
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true) //contrast the color of the text
        }
        
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
            destivacionVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: Delete data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error deleting: \(error)")
            }
            
            //tableView.reloadData()
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("error saving data \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //first with external parameter and request internal
    // "=" default value
    func loadCategories() {
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
}
