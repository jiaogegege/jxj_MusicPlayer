//
//  LrcParser.m
//  音乐播放器
//
//  Created by 蒋雪姣 on 15/12/20.
//  Copyright © 2015年 蒋雪姣. All rights reserved.
//

#import "LrcParser.h"

@implementation LrcParser
+(NSArray *)parserLrcFile:(NSString *)lrcFile
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSURL *url = [[NSBundle mainBundle] URLForResource:lrcFile withExtension:nil];
    if (url == nil)
    {
        return nil;
    }
    NSString *lrcContent = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    //提取时间和歌词字符串
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\d.*\n" options:0 error:nil];
    NSArray *array1 = [regex matchesInString:lrcContent options:0 range:NSMakeRange(0, [lrcContent length])];
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    [array1 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //获得时间和歌词字符串
        NSString *str = [regex replacementStringForResult:obj inString:lrcContent offset:0 template:@"$0"];
        [array2 addObject:str];
    }];
    //提取时间和歌词放入字典中
    //提取时间的正则表达式
    NSRegularExpression *timeRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=\\[).+(?=\\])" options:0 error:nil];
    NSMutableArray *timeArray = [[NSMutableArray alloc] init];
    //提取歌词的正则表达式
    NSRegularExpression *lrcRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=\\]).*(?=\n)" options:0 error:nil];
    NSMutableArray *lrcArray = [[NSMutableArray alloc] init];
    //开始提取时间和歌词
    [array2 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTextCheckingResult *timeResult = [timeRegex firstMatchInString:obj options:0 range:NSMakeRange(0, [obj length])];
        NSString *timeStr = [timeRegex replacementStringForResult:timeResult inString:obj offset:0 template:@"$0"];
        [timeArray addObject:timeStr];
        NSTextCheckingResult *lrcResult = [lrcRegex firstMatchInString:obj options:0 range:NSMakeRange(0, [obj length])];
        NSString *lrcStr = [lrcRegex replacementStringForResult:lrcResult inString:obj offset:0 template:@"$0"];
        [lrcArray addObject:lrcStr];
    }];
    //转换时间为double类型
    [timeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSArray *a = [obj componentsSeparatedByString:@":"];
        double minute = [a[0] doubleValue];
        double second = [a[1] doubleValue];
        double totalTime = minute * 60 + second;
        [dict setObject:@(totalTime) forKey:@"time"];
        [dict setObject:lrcArray[idx] forKey:@"lrc"];
        [result addObject:dict];
    }];
    return result;
}
@end
