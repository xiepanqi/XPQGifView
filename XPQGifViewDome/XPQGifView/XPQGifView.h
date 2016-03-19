//
//  XPQGifView.h
//  XPQGifViewDome
//
//  Created by 谢攀琪 on 16/3/19.
//  Copyright © 2016年 谢攀琪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XPQGifView : UIImageView
/// 无效初始化
- (instancetype)initWithImage:(UIImage *)image UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage UNAVAILABLE_ATTRIBUTE;
/// 是否在播放
@property (nonatomic, assign, readonly) BOOL isPlay;
/// 播放次数，设置为 NSUIntegerMax 表示无限播发。默认为NSUIntegerMax。
@property (nonatomic, assign) NSUInteger loopCount;
/// gif数据源。
@property (nonatomic, strong) NSData *gifData;

- (void)start;
- (void)suspend;
- (void)stop;
@end
