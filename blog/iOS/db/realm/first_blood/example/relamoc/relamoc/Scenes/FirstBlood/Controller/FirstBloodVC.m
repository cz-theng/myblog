/*******************************************************************************\
** relamoc:FirstBloodVC.m
** Created by CZ(cz.devnet@gmail.com) on 16/7/7
**
**  Copyright © 2016年 projm. All rights reserved.
\*******************************************************************************/


#import "FirstBloodVC.h"

#import <Realm/Realm.h>

@interface FirstBloodVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameLbl;
@property (weak, nonatomic) IBOutlet UITextField *ageLbl;
@property (weak, nonatomic) IBOutlet UITextField *ageFilterLbl;
@property (weak, nonatomic) IBOutlet UITableView *dataTV;
@end

@implementation FirstBloodVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dataTV.dataSource = self;
    _dataTV.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAdd:(id)sender {

}

- (IBAction)onQuery:(id)sender {
    
}

- (void) reloadTableData {

}


#pragma mark  UITableViewDataSourcen
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    [[cell textLabel] setText:@"NONE"];
    return cell;
}

#pragma mark UITableViewDelegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
