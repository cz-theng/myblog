/*******************************************************************************\
** realmcrud:ModifyVC.m
** Created by CZ(cz.devnet@gmail.com) on 16/7/8
**
**  Copyright © 2016年 projm. All rights reserved.
\*******************************************************************************/


#import "ModifyVC.h"
#import "Student.h"

@interface ModifyVC ()
@property (weak, nonatomic) IBOutlet UIButton *modifyBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;

@property (strong, nonatomic) RLMRealm * realm;
@property (strong, nonatomic) Student * student;

@end

@implementation ModifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (nil != _student) {
        [_nameTF setText:_student.name];
        [_ageTF setText:[NSString stringWithFormat:@"%d", _student.age]];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setReal: (RLMRealm *) realm student:(Student *) student {
    _realm = realm;
    _student = student;
    

}

- (IBAction)onModify:(id)sender {
    
    if (_nameTF.text.length ==0 || _ageTF.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty"
                                                        message:@"Name or Age is empty!"
                                                       delegate:self
                                              cancelButtonTitle:@"Return"
                                              otherButtonTitles:nil];
        [alert show];
        return ;
    }
    
    
    [_realm beginWriteTransaction];
    _student.name = _nameTF.text;
    _student.age = _ageTF.text.intValue;
    [_realm commitWriteTransaction];
    
    UINavigationController *vc = (UINavigationController *)self.parentViewController;
    [vc popViewControllerAnimated:YES];
}

@end
