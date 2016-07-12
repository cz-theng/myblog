//
//  Student.h
//  realmcrud
//
//  Created by apollo on 16/7/11.
//  Copyright © 2016年 projm. All rights reserved.
//

#import <Realm/Realm.h>

@interface Student : RLMObject
@property int age;
@property NSString *name;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Student>
RLM_ARRAY_TYPE(Student)
