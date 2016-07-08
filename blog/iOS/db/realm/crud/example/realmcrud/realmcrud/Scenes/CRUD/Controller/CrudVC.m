/*******************************************************************************\
** realmcrud:CrudVC.m
** Created by CZ(cz.devnet@gmail.com) on 16/7/8
**
**  Copyright © 2016年 projm. All rights reserved.
\*******************************************************************************/


#import "CrudVC.h"
#import "ModifyVC.h"

@interface CrudVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UITextField *filterTF;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *queryBtn;
@property (weak, nonatomic) IBOutlet UITableView *dataTV;

@end

@implementation CrudVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataTV.dataSource = self;
    _dataTV.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select at %ld", (long)indexPath.row);
    UINavigationController *vc = (UINavigationController *)self.parentViewController;
    
    ModifyVC *modifyVC = (ModifyVC *)[[UIStoryboard storyboardWithName:@"crud" bundle:nil] instantiateViewControllerWithIdentifier:@"modify_vc"];
    [vc pushViewController:modifyVC animated:YES];
}

@end
