//
//  Student.swift
//  firstbloodswift
//
//  Created by apollo on 16/7/8.
//  Copyright © 2016年 projm. All rights reserved.
//

import Foundation
import RealmSwift

class Student: Object {
    
    dynamic var name = "";
    dynamic var age = 0;
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
