//
//  SongsDetailController.h
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/20.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongsDetailController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,copy)NSString *playListName;

@end
