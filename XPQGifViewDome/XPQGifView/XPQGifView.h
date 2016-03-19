//
//  XPQGifView.h
//  XPQGifViewDome
//
//  Created by 谢攀琪 on 16/3/19.
//  Copyright © 2016年 谢攀琪. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 播放gif图片类。优化播放gif时内存占用过高。
 原理是时间换空间，播发时并不是把所有图片缓存到内存中，而是实时的从资源中读取图片显示。
 帧与帧的间隔越小CPU占用越大。
 另外还实现了gif动画的暂停、快进、慢放功能。
 */
@interface XPQGifView : UIImageView
/// 无效初始化
- (instancetype)initWithImage:(UIImage *)image UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithGifData:(NSData *)gifData;
/// 是否在播放
@property (nonatomic, assign, readonly) BOOL isPlay;
/// 播放次数，设置为 NSUIntegerMax 表示无限播发。默认为NSUIntegerMax。
@property (nonatomic, assign) NSUInteger loopCount;
/// gif数据源。
@property (nonatomic, strong) NSData *gifData;
/// 播发速度倍数，越大播发速度越慢，越小越快。实际播发速度＝原播发速度*sleep。默认1.0。
@property (nonatomic, assign) CGFloat sleep;

- (void)start;
- (void)suspend;
- (void)stop;
@end
