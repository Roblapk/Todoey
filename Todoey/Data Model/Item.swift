//
//  Item.swift
//  Todoey
//
//  Created by Rogelio Bernal on 11/27/18.
//  Copyright © 2018 Rogelio Bernal. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = "" //monitoring and set new values in realm database
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
