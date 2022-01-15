//
//  PlayListsController.m
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/20.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import "PlayListsController.h"
#import "MusicManager.h"
#import "SongsDetailController.h"

@interface PlayListsController ()
{
    __weak MusicManager *_manager;
    NSArray *_playLists;
    UITableView *_tableView;
}
@end

@implementation PlayListsController

- (void)viewDidLoad {
    [super viewDidLoad];
    _manager = [MusicManager defaultManager];
    _playLists = [_manager getAllPlayLists];
    // Do any additional setup after loading the view.
    [self createUI];
}

-(void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.contents = (id)[UIImage imageNamed:[NSString stringWithFormat:@"bgImage%d.png", arc4random()%11]].CGImage;
    self.title = @"播放列表";
    self.automaticallyAdjustsScrollViewInsets = YES;
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    _tableView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    //创建导航栏工具按钮
    UIBarButtonItem *createNewPlayListBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewPlayList)];
    self.navigationItem.rightBarButtonItem = createNewPlayListBtn;
    
}

//新建播放列表
-(void)createNewPlayList
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"新建播放列表" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"新建播放列表";
    }];
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = [controller.textFields[0] text];
        [_manager createNewPlayList:text];
        _playLists = [_manager getAllPlayLists];
        [_tableView reloadData];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - UITableView协议方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _playLists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _playLists[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:29/255.0 green:98/255.0 blue:157/255.0 alpha:1];
    return cell;
}

//选择表视图某一行执行的操作
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SongsDetailController *songCtl = [[SongsDetailController alloc] init];
    songCtl.playListName = cell.textLabel.text;
    [self.navigationController pushViewController:songCtl animated:YES];
    cell.selected = NO;
}

//实现cell侧滑删除按钮
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *listName = cell.textLabel.text;
        if ([listName isEqualToString:_manager.currentPlayList.playListName])
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前播放列表无法删除" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认删除" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //删除播放列表的代码
                BOOL ret = [_manager deletePlayList:listName];
                if (ret)
                {
                    _playLists = [_manager getAllPlayLists];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}
-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
//侧滑按钮删除文字
//-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"删除";
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
