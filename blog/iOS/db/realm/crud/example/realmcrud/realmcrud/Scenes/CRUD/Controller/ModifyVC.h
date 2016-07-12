/*******************************************************************************\
** realmcrud:ModifyVC.h
** Created by CZ(cz.devnet@gmail.com) on 16/7/8
**
**  Copyright © 2016年 projm. All rights reserved.
\*******************************************************************************/


#import <UIKit/UIKit.h>
#import "Student.h"
#import <Realm/Realm.h>

@interface ModifyVC : UIViewController
-(void) setReal: (RLMRealm *) realm student:(Student *) student;
@end
