//
//  PlayBackController.m
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/19.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import "PlayBackController.h"
#import "MusicManager.h"

@interface PlayBackController ()
{
    __weak MusicManager *_manager;
    NSTimer *_timer;
}
@end

@implementation PlayBackController

- (void)viewDidLoad {
    [super viewDidLoad];
    _manager = [MusicManager defaultManager];
    [_manager addObserver:self forKeyPath:@"defaultPlayer" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    // Do any additional setup after loading the view.
    [self createUI];
    [self setSongInfo];
    [self setPlayState];
}

-(void)createUI
{
    //界面阴影
    self.view.frame = CGRectMake(0, 567, [UIScreen mainScreen].bounds.size.width, 100);
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0, -5);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowRadius = 5;
    
    //图片效果
    self.singerImageView.layer.cornerRadius = 5;
    self.singerImageView.layer.masksToBounds = YES;
    
}

//读取播放模式
-(void)setPlayState
{
    if (_manager.playStatus == PlayStatusSingleCycle)
    {
        [self.stateBtn setImage:[UIImage imageNamed:@"singlePlay.png"] forState:UIControlStateNormal];
    }
    else if (_manager.playStatus == PlayStatusQueue)
    {
        [self.stateBtn setImage:[UIImage imageNamed:@"queuePlay.png"] forState:UIControlStateNormal];
    }
    else if (_manager.playStatus == PlayStatusRandom)
    {
        [self.stateBtn setImage:[UIImage imageNamed:@"randomPlay.png"] forState:UIControlStateNormal];
    }
}

//进度条和歌手／头像等，当前播放歌曲变化的时候调用
-(void)setSongInfo
{
    self.progressBar.maximumValue = _manager.defaultPlayer.duration;
    self.progressBar.value = 0;
    //设置初始时间
    int minute = _manager.defaultPlayer.duration / 60;
    int second = (int)_manager.defaultPlayer.duration % 60;
    self.endTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    
    //读取歌曲信息
    NSArray *singerNames = @[@"初音未来", @"初音ミク", @"Hatsune Miku"];
    self.songNameLabel.text = [_manager.currentSong stringByDeletingPathExtension];
    self.singerNameLabel.text = singerNames[arc4random()%singerNames.count];
    self.singerImageView.image = [UIImage imageNamed:[NSString  stringWithFormat:@"head%d.png", arc4random()%11]];
//    [self readMP3FileInfo];
}

//读取歌曲信息的方法
-(void)readMP3FileInfo
{
    NSString *songPath = [[NSBundle mainBundle] pathForResource:_manager.currentSong ofType:nil];
    NSURL *songURL = [NSURL fileURLWithPath:songPath];
    AVURLAsset *mp3Asset = [AVURLAsset URLAssetWithURL:songURL options:nil];
    for (NSString *format in [mp3Asset availableMetadataFormats])
    {
        for (AVMetadataItem *item in [mp3Asset metadataForFormat:format])
        {
            if ([item.commonKey isEqualToString:@"title"])
            {
                self.songNameLabel.text = [item stringValue];   //歌曲名
            }
            else if ([item.commonKey isEqualToString:@"artist"])
            {
                self.singerNameLabel.text = [item stringValue];
            }
//            else if ([item.commonKey isEqualToString:@"artwork"])
//            {
//                NSDictionary *dict = (NSDictionary *)item.value;
//                NSData *data = [dict objectForKey:@"data"];
//                self.singerImageView.image = [UIImage imageWithData:data];
//            }
        }
    }
}

//设置进度和时间条，定时器调用
-(void)setProgress
{
    self.progressBar.value = _manager.defaultPlayer.currentTime;
    //改变进度时间
    [self setTimeLabels];
}

//改变时间进度的方法
-(void)setTimeLabels
{
    //经过时间
    int beginMinute = _manager.defaultPlayer.currentTime/60;
    int beginSecond = (int)_manager.defaultPlayer.currentTime%60;
    self.beginTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", beginMinute, beginSecond];
    //剩余时间
    int endMinute = [_manager getRemainingTime]/60;
    int endSecond = (int)[_manager getRemainingTime] % 60;
    self.endTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", endMinute, endSecond];
}

//KVO观察属性
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"defaultPlayer"])
    {
        [self setSongInfo];
        [self.playBtn setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
        if (_timer == nil)
        {
            _timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
        }
    }
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

- (IBAction)previousButton:(UIButton *)sender {
    [_manager playPreviousMusic];
    [self.playBtn setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
    if (_timer == nil)
    {
        _timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
    }
}

- (IBAction)playButton:(UIButton *)sender {
    if (_manager.isPlayingMusic)
    {
        [_timer setFireDate:[NSDate distantFuture]];
        [_manager pausePlayer];
        [self.playBtn setImage:[UIImage imageNamed:@"playBtn.png"] forState:UIControlStateNormal];
    }
    else
    {
        if (_timer == nil)
        {
            _timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
        }
        else
        {
            [_timer setFireDate:[NSDate distantPast]];
        }
        [_manager playMusic];
        [self.playBtn setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)nextButton:(UIButton *)sender {
    [_manager playNextMusic];
    [self.playBtn setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
    if (_timer == nil)
    {
        _timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setProgress) userInfo:nil repeats:YES];
    }
}

- (IBAction)changeState:(UIButton *)sender {
    if (_manager.playStatus == PlayStatusQueue)
    {
        [self.stateBtn setImage:[UIImage imageNamed:@"randomPlay.png"] forState:UIControlStateNormal];
    }
    else if (_manager.playStatus == PlayStatusRandom)
    {
        [self.stateBtn setImage:[UIImage imageNamed:@"singlePlay.png"] forState:UIControlStateNormal];
    }
    else if (_manager.playStatus == PlayStatusSingleCycle)
    {
        [self.stateBtn setImage:[UIImage imageNamed:@"queuePlay.png"] forState:UIControlStateNormal];
    }
    [_manager changePlayStatus];
}

//改变播放进度
- (IBAction)changeProgress:(UISlider *)sender {
    [_manager changePlayProgress:sender.value];
    [self setTimeLabels];
}
@end
