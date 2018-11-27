//
//  ViewController.swift
//  Todoey
//
//  Created by Rogelio Bernal on 9/10/18.
//  Copyright © 2018 Rogelio Bernal. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController{
    
    var itemArray = [Item]()
    var selectedCategory: Category?{
        didSet{ //only when it has a new value
            loadItems()
        }
    }
    
    //let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath)
        
        // Do any additional setup after loading the view, typically from a nib.
        /*if let items = UserDefaults.standard.array(forKey: "TodoListArray") as? [String]{
            itemArray = items
        }*/
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        //cell.textLabel?.text = itemArray[indexPath.row]
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
         
        return cell
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(itemArray[indexPath.row])
        
        //tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark //add checkmark
        
        /*if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } old version*/
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true) //deselected row quickly
        
    }
    
    //MARK - add new items
    
    @IBAction func addButtonItem(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add button on our alert
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory //set the category selected
            //append new items
            self.itemArray.append(newItem)
            
            //add to userDefaults to store the data
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
            self.saveItems()
        }
        
        alert.addTextField {(alertTextField) in //add the textField
            alertTextField.placeholder = "Create new item"
            textField = alertTextField //pass the data of alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation
    
    func saveItems(){
        do{
           try context.save()
        }catch{
            print("error saving data \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //first with external parameter and request internal
    // "=" default value
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        
        if let addtionalPredicate = predicate{ //if content something
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate]) //if have something i gonna run both
        }else{
            request.predicate = categoryPredicate //if not only this one
        }
        
        do{
           itemArray = try context.fetch(request)
        }catch{
            print("error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest() //request to data
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!) //search by title that contains search.text
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems() //call the whole list
            
            DispatchQueue.main.async { //eject in main the method
                searchBar.resignFirstResponder() //return to the first status
            }
        }
    }
}

