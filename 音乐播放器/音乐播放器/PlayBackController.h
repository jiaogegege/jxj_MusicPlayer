//
//  PlayBackController.h
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/19.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayBackController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *progressBar;
@property (weak, nonatomic) IBOutlet UIImageView *singerImageView;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *stateBtn;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

- (IBAction)previousButton:(UIButton *)sender;
- (IBAction)playButton:(UIButton *)sender;
- (IBAction)nextButton:(UIButton *)sender;
- (IBAction)changeState:(UIButton *)sender;
- (IBAction)changeProgress:(UISlider *)sender;

@end
