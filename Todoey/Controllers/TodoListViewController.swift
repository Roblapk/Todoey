//
//  ViewController.swift
//  Todoey
//
//  Created by Rogelio Bernal on 9/10/18.
//  Copyright © 2018 Rogelio Bernal. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!

    var itemArray : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category?{
        didSet{ //only when it has a new value
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) { //before viewdidLoad

        //title is for the navigation title
        title = selectedCategory!.name //is not null
        
        guard let colorHex = selectedCategory?.color else {
            fatalError("Error color doesnt exist")
        }
        updateNavBar(withHexCode: colorHex) //set the color

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nav Bar Set Up Methos
    func updateNavBar(withHexCode colorHexCode: String) {
        
        //USE IF LET IF YOU THINK THAT YOUR CODE IT WILL FAIL IN A 50 %
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("navitation controller doesn't exist")
        }
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else{
            fatalError("error with the navBarColor")
        }
        navBar.barTintColor = navBarColor //background //change de color of the navigationBar
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true) //buttons in navigationBar
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)] //change the titles color
        
        searchBar.barTintColor = navBarColor // color for searchBar
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            //get the color from category
            if let colour = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)){ //gradient to the cells
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true) //contrast the color of the text
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No items Added"
        }
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArray?[indexPath.row]{
            do{
                try realm.write {
                    //realm.delete(item) delete method
                    item.done = !item.done
                }
            }catch{
                print("error: \(error)")
            }
        }
        /*itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()*/
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true) //deselected row quickly
        
    }
    
    //MARK - add new items
    
    @IBAction func addButtonItem(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add button on our alert
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem) //REPLACE PARENT CATEGORY = SELECTED CATEGORY
                    }
                }catch{
                    print("ERROR SAVING NEW ITEMS, \(error)")
                }
                
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField {(alertTextField) in //add the textField
            alertTextField.placeholder = "Create new item"
            textField = alertTextField //pass the data of alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation
    
    func loadItems(){
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = itemArray?[indexPath.row]{
            do{
                try realm.write {
                    realm.delete(item)
                }
            }catch{
                print("error deleting item, \(error)")
            }
        }
    }
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true) //equivalent all four lines before in core data
        tableView.reloadData()
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

