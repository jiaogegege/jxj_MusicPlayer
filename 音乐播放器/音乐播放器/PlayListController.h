//
//  PlayListController.h
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/19.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *lrcView;
@property (weak, nonatomic) IBOutlet UIPickerView *lrcPickerView;

- (IBAction)playListBtn:(UIButton *)sender;
- (IBAction)loveSongsBtn:(UIButton *)sender;
- (IBAction)downloadBtn:(UIButton *)sender;
- (IBAction)searchBtn:(UIButton *)sender;

@end
