//
//  PlayList.h
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/19.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayList : NSObject<NSCoding>

@property(nonatomic,copy)NSString *playListName;    //播放列表的名字
@property(nonatomic,strong)NSMutableArray *songsList;   //播放列表中的所有歌曲列表

//给播放数组添加歌曲名的方法
-(void)addSongsListObject:(NSString *)object;

//通过序号获得歌曲的文件名
-(NSString *)getSongNameWithIndex:(NSInteger)index;

//获得播放列表中歌曲的数目
-(NSInteger)getNumberOfSongs;

//获得播放列表中的歌曲
-(NSArray *)getPlayListSongs;
@end
