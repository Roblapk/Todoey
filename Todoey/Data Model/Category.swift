//
//  Category.swift
//  Todoey
//
//  Created by Rogelio Bernal on 11/27/18.
//  Copyright © 2018 Rogelio Bernal. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = "" //monitoring and set new values in realm database
    let items = List<Item>() //empty list
}
