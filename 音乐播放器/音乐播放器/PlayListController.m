//
//  PlayListController.m
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/19.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import "PlayListController.h"
#import "MusicManager.h"
#import "PlayListsController.h"
#import "LrcParser.h"
#import "SearchViewController.h"
#import <CoreText/CoreText.h>

@interface PlayListController ()
{
    __weak MusicManager *_manager;
    //更换背景的定时器
    NSTimer *_changeBGImageTimer;
    //歌词数组
    NSArray *_lrcArray;
    NSTimer *_lrcTimer;
}
@end

@implementation PlayListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _manager = [MusicManager defaultManager];
    
    // Do any additional setup after loading the view from its nib.
    [self createLrcData];
    [self createUI];
    
    [self setBackImageAndTitle];
    [_manager addObserver:self forKeyPath:@"currentSong" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    //定时器
    _lrcTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeLrc) userInfo:nil repeats:YES];
    _changeBGImageTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(setBackImageAndTitle) userInfo:nil repeats:YES];
}

//改变歌词显示的方法
-(void)changeLrc
{
    NSTimeInterval playerTime = _manager.defaultPlayer.currentTime;
    if (playerTime < [[_lrcArray[_lrcArray.count-1] objectForKey:@"time"] doubleValue])
    {
        for (int i = 0; i < _lrcArray.count - 1; ++i)
        {
            NSTimeInterval time1 = [[_lrcArray[i] objectForKey:@"time"] doubleValue];
            NSTimeInterval time2 = [[_lrcArray[i+1] objectForKey:@"time"] doubleValue];
            if (playerTime >= time1 && playerTime < time2)
            {
                [self.lrcPickerView selectRow:i inComponent:0 animated:YES];
                break;
            }
        }
    }
    else
    {
        [self.lrcPickerView selectRow:_lrcArray.count-1 inComponent:0 animated:YES];
    }
}


//KVO属性观察器
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentSong"])
    {
        self.title = [_manager.currentSong stringByDeletingPathExtension];
        [self createLrcData];
        [self.lrcPickerView reloadAllComponents];
        [self.lrcPickerView selectRow:0 inComponent:0 animated:NO];
    }
}

//创建歌词数据
-(void)createLrcData
{
    _lrcArray = nil;
    //读取歌词文件
    NSString *lrcFileName = [[_manager.currentSong stringByDeletingPathExtension] stringByAppendingPathExtension:@"lrc"];
    _lrcArray = [LrcParser parserLrcFile:lrcFileName];
}

-(void)createUI
{
    self.view.frame = CGRectMake(0, 400, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100);
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:97/255.0 green:203/255.0 blue:255/255.0 alpha:1];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    self.lrcView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    
    //修改返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    //UIPickerView的一些初始化工作
    self.lrcPickerView.dataSource = self;
    self.lrcPickerView.delegate = self;
}

#pragma mark - UIPickerView协议方法
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _lrcArray.count;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.text = [[_lrcArray objectAtIndex:row] objectForKey:@"lrc"];
    label.textColor = [UIColor colorWithRed:29/255.0 green:125/255.0 blue:242/255.0 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

//拖动歌词改变播放进度
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSTimeInterval time = [[_lrcArray[row] objectForKey:@"time"] doubleValue];
    [_manager changePlayProgress:time];
}

//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return [_lrcArray objectAtIndex:row];
//}

#pragma mark - 界面的一些设置工作
//设置背景图片
-(void)setBackImageAndTitle
{
    self.title = [_manager.currentSong stringByDeletingPathExtension];
    self.view.layer.contents = (id)[UIImage imageNamed:[NSString stringWithFormat:@"bgImage%d.png", arc4random()%11]].CGImage;
    CATransition *trans = [CATransition animation];
    trans.duration = 1;
    trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    trans.type = kCATransitionFade;
    [self.view.layer addAnimation:trans forKey:@"contents"];
}


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

- (IBAction)playListBtn:(UIButton *)sender {
    //进入播放列表界面
    PlayListsController *playLists = [[PlayListsController alloc] init];
    [self.navigationController pushViewController:playLists animated:YES];
}

- (IBAction)loveSongsBtn:(UIButton *)sender {
}

- (IBAction)downloadBtn:(UIButton *)sender {
}

- (IBAction)searchBtn:(UIButton *)sender {
    SearchViewController *search = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
}
@end
