//
//  Student.h
//  firstblood
//
//  Created by apollo on 16/7/8.
//  Copyright © 2016年 projm. All rights reserved.
//

#import <Realm/Realm.h>

@interface Student : RLMObject
@property NSString *name;
@property NSInteger age;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Student>
RLM_ARRAY_TYPE(Student)
