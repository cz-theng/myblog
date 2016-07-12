/*******************************************************************************\
** realmcrud:CrudVC.m
** Created by CZ(cz.devnet@gmail.com) on 16/7/8
**
**  Copyright © 2016年 projm. All rights reserved.
\*******************************************************************************/


#import "CrudVC.h"
#import "ModifyVC.h"
#import "Student.h"
#import <Realm/Realm.h>

@interface CrudVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UITextField *filterTF;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *queryBtn;
@property (weak, nonatomic) IBOutlet UITableView *dataTV;
@property (strong, nonatomic) RLMRealm *realm;
@property (strong, nonatomic) RLMResults<Student *> *allStudents;
@end

@implementation CrudVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataTV.dataSource = self;
    _dataTV.delegate = self;
    [self initRealm];
    _allStudents = [Student allObjectsInRealm:_realm];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) initRealm {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
                       URLByAppendingPathComponent:@"crud"]
                      URLByAppendingPathExtension:@"realm"];
    NSLog(@"Realm file path: %@", config.fileURL);
    NSError *error;
    _realm = [RLMRealm realmWithConfiguration:config error:&error];
    if (nil != error) {
        NSLog(@"Create Realm Error");
        return NO;
    }
    NSLog(@"create realm success");
    return YES;
}

- (IBAction)onAdd:(id)sender {
    if (_nameTF.text.length ==0 || _ageTF.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty"
                                                        message:@"Name or Age is empty!"
                                                       delegate:self
                                              cancelButtonTitle:@"Return"
                                              otherButtonTitles:nil];
        [alert show];
        return ;
    }
    Student *s= [Student new];
    s.name = _nameTF.text;
    s.age = [_ageTF.text intValue];
    
    [_realm beginWriteTransaction];
    [_realm addObject:s];
    [_realm commitWriteTransaction];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sucess"
                                                    message:@"Add Sucess!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    _allStudents = [Student allObjectsInRealm:_realm];
    [_dataTV reloadData];

}

- (IBAction)onQuery:(id)sender {
    if (_filterTF.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty"
                                                        message:@"Filter Age is empty!"
                                                       delegate:self
                                              cancelButtonTitle:@"Return"
                                              otherButtonTitles:nil];
        [alert show];
        return ;
    }
    
    NSString *filter = [NSString stringWithFormat:@"age > %d", [_filterTF.text intValue ]];
    _allStudents = [Student objectsInRealm:_realm where:filter];
    [_dataTV reloadData];
}

#pragma mark  UITableViewDataSourcen
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (nil == _allStudents) {
        return 0;
    }
    return [_allStudents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (_allStudents.count < indexPath.row+1) {
        [[cell textLabel] setText:@"NONE"];
        return cell;
    }

    Student *s = [_allStudents objectAtIndex:indexPath.row];
    [[cell textLabel] setText:s.name];
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select at %ld", (long)indexPath.row);
    UINavigationController *vc = (UINavigationController *)self.parentViewController;
    
    Student *s = [_allStudents objectAtIndex:indexPath.row];
    
    ModifyVC *modifyVC = (ModifyVC *)[[UIStoryboard storyboardWithName:@"crud" bundle:nil] instantiateViewControllerWithIdentifier:@"modify_vc"];
    [modifyVC setReal:_realm student:s];
    [vc pushViewController:modifyVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Student *s = [_allStudents objectAtIndex:indexPath.row];
    if (s == nil) {
        NSLog(@"s is nil");
        return;
    }
    [_realm beginWriteTransaction];
    [_realm deleteObject:s];
    [_realm commitWriteTransaction];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


@end
