//
//  main.m
//  firstblood
//
//  Created by apollo on 16/7/7.
//  Copyright © 2016年 projm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Student.h"

NSString *jsonData = @"[{\"name\":\"wangmeimei\",\"age\":13},{\"name\":\"lilei\",\"age\":14}]";



void demo4realm() {
    NSError *error;
    NSMutableArray *students = [NSJSONSerialization JSONObjectWithData:[jsonData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (nil != error) {
        NSLog(@"Parse JSON Error %@", error);
        return ;
    }
    RLMRealm *realmMgr = [RLMRealm defaultRealm];
    NSLog(@"db file is %@",realmMgr.configuration.fileURL);
    for (NSDictionary *s in students) {
        Student *student = [Student new];
        student.age = [[s valueForKey:@"age"] intValue];
        student.name = [s valueForKey:@"name"];
        [realmMgr transactionWithBlock:^{
            [realmMgr addObject:student];
        }];
    }
    
    RLMResults<Student *> *allStudents = [Student allObjects];
    NSLog(@"All students' count %lu", (unsigned long)[allStudents count]);
    RLMResults<Student *> *fs = [allStudents objectsWhere:@"age > 13"];

    for (int i=0; i<[fs count]; i++) {
        Student *s = [fs objectAtIndex:i];
        NSLog(@"Name %@ age is %ld", s.name , (long)s.age);
    }

}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        demo4realm();
    }
    return 0;
}
