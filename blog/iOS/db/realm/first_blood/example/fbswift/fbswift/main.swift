//
//  main.swift
//  fbswift
//
//  Created by apollo on 16/7/8.
//  Copyright © 2016年 projm. All rights reserved.
//

import Foundation
import RealmSwift

let jsonData  = "[{\"name\":\"wangmeimei\",\"age\":13},{\"name\":\"lilei\",\"age\":14}]"

func demo4realm() {
    print(jsonData)
    var error: NSError?
    let students : NSArray = try! NSJSONSerialization.JSONObjectWithData(jsonData.dataUsingEncoding(NSUTF8StringEncoding)!,
                                                                         options: NSJSONReadingOptions.MutableContainers) as! NSArray
    let realmMgr = try! Realm()
    print("default db is ", realmMgr.configuration.fileURL)
    
    for s in students {
        let student = Student()
        student.name  = s.objectForKey("name") as! String
        student.age = s.objectForKey("age") as! Int
        
        try! realmMgr.write {
            realmMgr.add(student)
        }
    }
    
    let pups = realmMgr.objects(Student.self).filter("age > 13")
    for (var i=0; i<pups.count ; i++) {
        let s = pups[i];
        print("Name %@ age is %ld", s.name, s.age);
    }
    
}

demo4realm()


