//
//  PlayList.m
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/19.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import "PlayList.h"

@implementation PlayList

//初始化方法
-(instancetype)init
{
    if (self = [super init])
    {
        self.songsList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.playListName forKey:@"playListName"];
    [aCoder encodeObject:self.songsList forKey:@"songsList"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.playListName = [aDecoder decodeObjectForKey:@"playListName"];
        self.songsList = [aDecoder decodeObjectForKey:@"songsList"];
    }
    return self;
}

//添加歌曲的方法
-(void)addSongsListObject:(NSString *)object
{
    [self.songsList addObject:object];
}

//查找歌曲名的方法
-(NSString *)getSongNameWithIndex:(NSInteger)index
{
    return self.songsList[index];
}

//获得播放列表中歌曲的数目
-(NSInteger)getNumberOfSongs
{
    return self.songsList.count;
}

//获得播放列表中的歌曲
-(NSArray *)getPlayListSongs
{
    return [self.songsList copy];
}

@end
