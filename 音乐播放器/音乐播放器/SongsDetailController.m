//
//  SongsDetailController.m
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/20.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import "SongsDetailController.h"
#import "MusicManager.h"

@interface SongsDetailController ()
{
    MusicManager *_manager;
    NSArray *_songsArray;
    UITableView *_tableView;
    UITableViewCell *_currentSelectedSong;
}
@end

@implementation SongsDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    _manager = [MusicManager defaultManager];
    [_manager addObserver:self forKeyPath:@"currentSong" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    _songsArray = [_manager getPlayListSongs:self.playListName];
    // Do any additional setup after loading the view.
    [self createUI];
}

-(void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.contents = (id)[UIImage imageNamed:[NSString stringWithFormat:@"bgImage%d.png", arc4random()%11]].CGImage;
    self.title = self.playListName;
    //创建歌曲列表
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    _tableView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
}

#pragma mark - UITableView协议方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *songName = _songsArray[indexPath.row];
    if ([songName isEqualToString:_manager.currentSong])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _currentSelectedSong = cell;
    }
    cell.textLabel.text = [songName stringByDeletingPathExtension];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:29/255.0 green:98/255.0 blue:157/255.0 alpha:1];
    return cell;
}

//选择某行时执行的操作
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentSelectedSong.accessoryType = UITableViewCellAccessoryNone;
    _currentSelectedSong = [tableView cellForRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [_manager playMusic:[cell.textLabel.text stringByAppendingPathExtension:@"mp3"] andPlayListName:self.playListName];
}

//属性监听器
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentSong"])
    {
        _currentSelectedSong.accessoryType = UITableViewCellAccessoryNone;
        [_songsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:_manager.currentSong])
            {
                NSIndexPath *index = [NSIndexPath indexPathForRow:idx inSection:0];
                UITableViewCell *cell = [_tableView cellForRowAtIndexPath:index];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                _currentSelectedSong = cell;
                *stop = YES;
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_manager removeObserver:self forKeyPath:@"currentSong"];
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
