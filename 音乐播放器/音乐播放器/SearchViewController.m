//
//  SearchViewController.m
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/22.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import "SearchViewController.h"
#import "MusicManager.h"
#import <CoreText/CoreText.h>

@interface SearchViewController ()
{
    UITableView *_tableView;
    NSArray *_resultArray;
    __weak MusicManager *_manager;
    NSMutableArray *_dataArray;
    UISearchController *_searchController;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [[NSMutableArray alloc] init];
    _manager = [MusicManager defaultManager];
    //获得数据
    NSArray *array = [_manager getPlayListSongs:@"默认列表"];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_dataArray addObject:[obj stringByDeletingPathExtension]];
    }];
    
    //设置界面
    self.view.backgroundColor = [UIColor whiteColor];
//    self.view.layer.contents = (id)[UIImage imageNamed:[NSString stringWithFormat:@"bgImage%d.png", arc4random()%11]].CGImage;
    self.tableView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"resultCell"];
    //搜索控件
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [_searchController.searchBar sizeToFit];
    _searchController.searchBar.placeholder = @"搜索海量音乐资源";
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.searchResultsUpdater = self;
    self.navigationItem.titleView = _searchController.searchBar;
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchController.searchBar.text];
    _resultArray = [_dataArray filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _resultArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell" forIndexPath:indexPath];
    cell.textLabel.text = _resultArray[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed:29/255.0 green:98/255.0 blue:157/255.0 alpha:1];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [_manager playMusic:[cell.textLabel.text stringByAppendingPathExtension:@"mp3"] andPlayListName:@"默认列表"];
    [self.navigationController popViewControllerAnimated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
