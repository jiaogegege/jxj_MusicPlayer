//
//  MusicManager.h
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/19.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayList.h"

typedef NS_ENUM(NSInteger, PlayStatus)
{
    PlayStatusSingleCycle = 0,  //单曲循环
    PlayStatusQueue,    //顺序播放
    PlayStatusRandom,   //随机播放
};

@interface MusicManager : NSObject<NSCopying, AVAudioPlayerDelegate>

@property(nonatomic,strong)AVAudioPlayer *defaultPlayer;    //全局播放器
@property(nonatomic,copy)NSString *currentSong;     //当前播放的歌曲名字
@property(nonatomic,strong)PlayList *currentPlayList;   //当前播放列表
@property(nonatomic,strong)NSMutableArray *playLists;   //播放列表数组
@property(nonatomic,assign)PlayStatus playStatus;    //播放状态（随机、单曲循环、顺序播放）

+(instancetype)defaultManager;
-(void)loadMusicInfo;
-(void)playMusic:(NSString *)songName andPlayListName:(NSString *)listName;
-(void)pausePlayer;
-(void)playNextMusic;
-(void)playPreviousMusic;
-(void)changePlayStatus;
-(BOOL)isPlayingMusic;
-(void)playMusic;
-(void)changePlayProgress:(double)progress;
-(NSTimeInterval)getRemainingTime;
-(NSArray *)getAllPlayLists;
-(NSArray *)getPlayListSongs:(NSString *)listName;
-(void)createNewPlayList:(NSString *)listName;
-(BOOL)deletePlayList:(NSString *)listName;
@end
