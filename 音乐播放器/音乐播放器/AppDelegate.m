//
//  AppDelegate.m
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/19.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import "AppDelegate.h"
#import "MusicManager.h"
#import "PlayBackController.h"
#import "PlayListController.h"

@interface AppDelegate ()
{
    PlayBackController *_playBackCtl;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //设置导航栏默认样式
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:44/255.0 green:130/255.0 blue:230/255.0 alpha:1]}];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:97/255.0 green:203/255.0 blue:255/255.0 alpha:1]];
    //加载播放列表
    MusicManager *manager;
    manager = [MusicManager defaultManager];
    [manager loadMusicInfo];
//    [manager.defaultPlayer play];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    //创建播放控件视图
    PlayListController *root = [[PlayListController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
    self.window.rootViewController = nav;
    _playBackCtl = [[PlayBackController alloc] init];
    [self.window addSubview:_playBackCtl.view];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil]];
    [application setApplicationIconBadgeNumber:10];
    
//    NSString *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
//    NSLog(@"%@", path);
//    NSString *bundle = [[NSBundle mainBundle] bundlePath];
//    NSLog(@"%@", bundle);
//    NSString *currentSong = @"初音未来";
//    PlayList *currentList = [[PlayList alloc] init];
//    NSArray *lists = @[currentList, [[PlayList alloc] init], [[PlayList alloc] init]];
    
    
//    manager.currentSong = currentSong;
//    manager.currentPlayList = currentList;
//    manager.playLists = [lists mutableCopy];
//    [manager saveCurrentPlayList];
//    [manager saveCurrentSongAndPlayList];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
