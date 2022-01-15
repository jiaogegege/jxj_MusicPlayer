//
//  MusicManager.m
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/19.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import "MusicManager.h"

@interface MusicManager()
{
    NSMutableArray *_songsIndex;
    NSInteger _currentIndex;
}
@end

@implementation MusicManager

static MusicManager *_instance = nil;
//获取单例类方法
+(instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

//重写拷贝和初始化方法
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

-(id)copyWithZone:(NSZone *)zone
{
    return [MusicManager defaultManager];
}

#pragma mark - 加载播放列表和保存播放列表方法
//加载播放列表
-(void)loadMusicInfo
{
    //初始化播放列表数组
    self.playLists = [[NSMutableArray alloc] init];
    //初始化当前播放列表序号数组
    _songsIndex = [[NSMutableArray alloc] init];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    BOOL ret = [user boolForKey:@"exist"];
    if (ret)
    {
        self.currentSong = [user objectForKey:@"currentSong"];
        self.playStatus = [user integerForKey:@"playStatus"];
        //读取当前播放列表，NSData类型
        NSData *currentData = [user objectForKey:@"currentPlayList"];
        self.currentPlayList = [NSKeyedUnarchiver unarchiveObjectWithData:currentData];
        //添加歌曲序号数组
        for (int i = 0; i < [self.currentPlayList getNumberOfSongs]; ++i)
        {
            [_songsIndex addObject:@(i)];
        }
        //当前播放歌曲的序号
        [_songsIndex enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[self.currentPlayList getSongNameWithIndex:[obj integerValue]] isEqualToString:self.currentSong])
            {
                _currentIndex = [obj integerValue];
                *stop = YES;
            }
        }];
        //读取播放列表数组,NSData类型
        NSArray *array = [user objectForKey:@"playLists"];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PlayList *aList = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
            [self.playLists addObject:aList];
        }];
        //创建播放器
        [self createPlayer];
    }
    else
    {
        //创建默认播放列表
        [user setBool:YES forKey:@"exist"];
        //设置默认播放模式：顺序播放
        self.playStatus = PlayStatusQueue;
        //获得默认歌曲信息
        NSArray *songArray = @[@"歌に形はないけれど.mp3", @"09 君に嘘.mp3", @"04 夕日坂.mp3", @"星空に願いを込めて -Good Night.mp3", @"01 星のカケラ.mp3", @"14 bouquet.mp3", @"初音未来 - Letter Song.mp3", @"04 夢と葉桜　_　青木月光 feat. 初音ミク.mp3", @"初音未来 - Starduster.mp3", @"初音未来、黒うさp - 虹色蝶々.mp3"];
        //设置当前播放歌曲为第1首
        self.currentSong = songArray[0];
        //设置当前默认播放列表
        self.currentPlayList = [[PlayList alloc] init];
        self.currentPlayList.playListName = @"默认列表";
        [songArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.currentPlayList addSongsListObject:obj];
        }];
        //添加歌曲序号数组
        for (int i = 0; i < [self.currentPlayList getNumberOfSongs]; ++i)
        {
            [_songsIndex addObject:@(i)];
        }
        _currentIndex = 0;
        //添加到播放列表数组
        [self.playLists addObject:self.currentPlayList];
        //保存播放信息
        [self savePlayStatus];
        [self saveCurrentSong];
        [self saveCurrentPlayListAndLists];
        //创建播放器
        [self createPlayer];
    }
}

//新建播放列表
-(void)createNewPlayList:(NSString *)listName
{
    PlayList *newList = [[PlayList alloc] init];
    newList.playListName = listName;
    [self.playLists addObject:newList];
    [self saveCurrentPlayListAndLists];
}

//创建播放器的方法
-(void)createPlayer
{
    self.defaultPlayer = nil;
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:self.currentSong withExtension:nil];
    NSError *error;
    self.defaultPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];
    self.defaultPlayer.delegate = self;
    if (error)
    {
        NSLog(@"error:%@", error.localizedDescription);
    }
}

#pragma mark - 保存播放信息，NSUserDefaults
//NSUserDefaults保存当前播放歌曲
-(void)saveCurrentSong
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:self.currentSong forKey:@"currentSong"];
    [user synchronize];
}
//NSUserDefaults保存当前播放列表和播放列表数组
-(void)saveCurrentPlayListAndLists
{
    //当前播放列表
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSData *currentData = [NSKeyedArchiver archivedDataWithRootObject:self.currentPlayList];
    [user setObject:currentData forKey:@"currentPlayList"];
    //播放列表数组
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self.playLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *playlistData = [NSKeyedArchiver archivedDataWithRootObject:obj];
        [array addObject:playlistData];
    }];
    [user setObject:[array copy] forKey:@"playLists"];
    [user synchronize];
}
//保存播放状态（随机、单曲、顺序）
-(void)savePlayStatus
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setInteger:self.playStatus forKey:@"playStatus"];
    [user synchronize];
}

#pragma mark - 对AVAudioPlayer的操作
//选择某一首歌曲开始播放
-(void)playMusic:(NSString *)songName andPlayListName:(NSString *)listName
{
    if ([self.currentSong isEqualToString:songName])
    {
        [self.defaultPlayer prepareToPlay];
        [self.defaultPlayer play];
    }
    else
    {
        self.currentSong = songName;
        self.defaultPlayer = nil;
        NSURL *url = [[NSBundle mainBundle] URLForResource:songName withExtension:nil];
        NSError *error;
        self.defaultPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.defaultPlayer.delegate = self;
        [self.defaultPlayer prepareToPlay];
        [self.defaultPlayer play];
        //存储当前播放的歌曲
        [self saveCurrentSong];
        //改变当前播放列表并存储
        if (![self.currentPlayList.playListName isEqualToString:listName])
        {
            [self.playLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[obj playListName] isEqualToString:listName])
                {
                    self.currentPlayList = obj;
                    *stop = YES;
                }
            }];
            [_songsIndex removeAllObjects];
            for (int i = 0; i < self.currentPlayList.songsList.count; ++i)
            {
                [_songsIndex addObject:@(i)];
            }
            //当前播放歌曲的序号
            [_songsIndex enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[self.currentPlayList getSongNameWithIndex:[obj integerValue]] isEqualToString:self.currentSong])
                {
                    _currentIndex = [obj integerValue];
                    *stop = YES;
                }
            }];
            [self saveCurrentPlayListAndLists];
        }
    }
}
//单击播放按钮的操作
-(void)playMusic
{
    [self.defaultPlayer play];
}
//单击暂停按钮执行的操作
-(void)pausePlayer
{
    [self.defaultPlayer pause];
}
//单击下一首按钮执行的操作
-(void)playNextMusic
{
    //顺序播放和单曲循环的情况
    if (self.playStatus == PlayStatusQueue || self.playStatus == PlayStatusSingleCycle)
    {
        [_songsIndex removeAllObjects];
        for (int i = 0; i < [self.currentPlayList getNumberOfSongs]; ++i)
        {
            [_songsIndex addObject:@(i)];
        }
        _currentIndex++;
        if (_currentIndex == [self.currentPlayList getNumberOfSongs])
        {
            _currentIndex = 0;
        }
        NSString *songName = [self.currentPlayList getSongNameWithIndex:_currentIndex];
        self.currentSong = songName;
        [self saveCurrentSong];
        [self createPlayer];
        [self.defaultPlayer prepareToPlay];
        [self.defaultPlayer play];
    }
    else
    {
        //随机播放的情况
        if (_songsIndex.count == 1)
        {
            [_songsIndex removeAllObjects];
            //添加歌曲序号数组
            for (int i = 0; i < [self.currentPlayList getNumberOfSongs]; ++i)
            {
                [_songsIndex addObject:@(i)];
            }
        }
        else
        {
            __weak typeof(_songsIndex) weakSongsIndex = _songsIndex;
            [_songsIndex enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj integerValue] == _currentIndex)
                {
                    [weakSongsIndex removeObject:obj];
                    *stop = YES;
                }
            }];
        }
        //重新随机获得歌曲序号
        _currentIndex = [_songsIndex[arc4random()%_songsIndex.count] integerValue];
        //创建播放器
        NSString *songName = [self.currentPlayList getSongNameWithIndex:_currentIndex];
        self.currentSong = songName;
        [self saveCurrentSong];
        [self createPlayer];
        [self.defaultPlayer prepareToPlay];
        [self.defaultPlayer play];
    }
}
//单击上一首按钮执行的操作
-(void)playPreviousMusic
{
    //单击上一首没有随机播放效果，只是播放列表中的上一首歌曲
    _currentIndex--;
    if (_currentIndex == -1)
    {
        _currentIndex = [self.currentPlayList getNumberOfSongs] - 1;
    }
    NSString *songName = [self.currentPlayList getSongNameWithIndex:_currentIndex];
    self.currentSong = songName;
    [self saveCurrentSong];
    [self createPlayer];
    [self.defaultPlayer prepareToPlay];
    [self.defaultPlayer play];
}
//单击切换播放模式执行的操作
-(void)changePlayStatus
{
    if (self.playStatus == PlayStatusSingleCycle)
    {
        self.playStatus = PlayStatusQueue;
    }
    else if (self.playStatus == PlayStatusQueue)
    {
        self.playStatus = PlayStatusRandom;
    }
    else if (self.playStatus == PlayStatusRandom)
    {
        self.playStatus = PlayStatusSingleCycle;
    }
    [self savePlayStatus];
}
//改变播放进度
-(void)changePlayProgress:(double)progress
{
    self.defaultPlayer.currentTime = progress;
}
//是否在播放
-(BOOL)isPlayingMusic
{
    return self.defaultPlayer.isPlaying;
}

//获得歌曲剩余时间
-(NSTimeInterval)getRemainingTime
{
    return self.defaultPlayer.duration - self.defaultPlayer.currentTime;
}

//获得所有播放列表名
-(NSArray *)getAllPlayLists
{
    NSMutableArray *listNames = [[NSMutableArray alloc] init];
    [self.playLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [listNames addObject:[obj playListName]];
    }];
    return listNames;
}

//获得播放列表中的歌曲名
-(NSArray *)getPlayListSongs:(NSString *)listName
{
    __block NSArray *array;
    [self.playLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger id, BOOL * _Nonnull stop) {
        if ([[obj playListName] isEqualToString:listName])
        {
            array = [obj getPlayListSongs];
        }
    }];
    return array;
}

//删除播放列表
-(BOOL)deletePlayList:(NSString *)listName
{
    if (![listName isEqualToString:self.currentPlayList.playListName])
    {
        //不是当前播放列表的时候才执行删除操作
        [self.playLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([listName isEqualToString:[obj playListName]])
            {
                [self.playLists removeObject:obj];
                [self saveCurrentPlayListAndLists];
                *stop = YES;
            }
        }];
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - AVAudioPlayerDelegate协议方法
//一首歌播放结束后执行的操作
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.playStatus == PlayStatusSingleCycle)
    {
        [self createPlayer];
        [self.defaultPlayer prepareToPlay];
        [self.defaultPlayer play];
    }
    else if (self.playStatus == PlayStatusQueue)
    {
        _currentIndex++;
        if (_currentIndex == [self.currentPlayList getNumberOfSongs])
        {
            _currentIndex = 0;
        }
        NSString *songName = [self.currentPlayList getSongNameWithIndex:_currentIndex];
        self.currentSong = songName;
        [self saveCurrentSong];
        [self createPlayer];
        [self.defaultPlayer prepareToPlay];
        [self.defaultPlayer play];
    }
    else if (self.playStatus == PlayStatusRandom)
    {
        if (_songsIndex.count == 1)
        {
            [_songsIndex removeAllObjects];
            //添加歌曲序号数组
            for (int i = 0; i < [self.currentPlayList getNumberOfSongs]; ++i)
            {
                [_songsIndex addObject:@(i)];
            }
        }
        else
        {
            __weak typeof(_songsIndex) weakSongsIndex = _songsIndex;
            [_songsIndex enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj integerValue] == _currentIndex)
                {
                    [weakSongsIndex removeObject:obj];
                    *stop = YES;
                }
            }];
        }
        //重新随机获得歌曲序号
        _currentIndex = [_songsIndex[arc4random()%_songsIndex.count] integerValue];
        //创建播放器
        NSString *songName = [self.currentPlayList getSongNameWithIndex:_currentIndex];
        self.currentSong = songName;
        [self saveCurrentSong];
        [self createPlayer];
        [self.defaultPlayer prepareToPlay];
        [self.defaultPlayer play];
    }
}
//一首歌解码失败后执行的操作
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"error:%@", error.localizedDescription);
}

@end
