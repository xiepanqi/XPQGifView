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

/// 初始化XPQGifView
- (instancetype)initWithGifData:(NSData *)gifData;
- (instancetype)initWithGifData:(NSData *)gifData andLoopCount:(NSUInteger)loopCount;
/// 无效初始化
- (instancetype)initWithImage:(UIImage *)image UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage UNAVAILABLE_ATTRIBUTE;

/// 是否在播放
@property (nonatomic, assign, readonly) BOOL isPlay;
/// 播放次数，设置为 NSUIntegerMax 表示无限播发。默认为NSUIntegerMax。
@property (nonatomic, assign) NSUInteger loopCount;
/// 播发速度倍数，越大播发速度越慢，越小越快。实际播发速度＝原播发速度*sleep。默认1.0。
@property (nonatomic, assign) CGFloat sleep;
/// 内存占比。默认NSUIntegerMax。该值表示隔多少帧保存一次缓存，为0表示全部保存，大于frameCount全部不保存。
/// 值越小占用内存越大，消耗CPU越小。修改此值必须要动画下次启动才生效。此值根据实际使用情况来设置。
@property (nonatomic, assign) NSUInteger frameCacheInterval;
/// gif数据源。
@property (nonatomic, strong) NSData *gifData;

/**
 *  @brief 启动无限播发GIF，如果gifData为nil则不做任何操作。
 */
- (void)start;
/**
 *  @brief 指定次数播发GIF，如果gifData为nil则不做任何操作。
 *  @param loopCount 重复播发次数
 */
- (void)startLoopCount:(NSUInteger)loopCount;
/**
 *  @brief 暂停播发GIF，再次使用start时从暂停的帧开始播发。
 */
- (void)suspend;
/**
 *  @brief 停止播发GIF，再次使用start时从第一帧开始播发。
 */
- (void)stop;

/**
 *  @brief 获取GIF的指定帧的显示时长。
 *  @param gifData GIF图片数据源
 *  @param index   帧索引
 *  @return 帧显示时长
 */
+ (NSTimeInterval)delayTimeWithGifData:(NSData *)gifData andIndex:(size_t)index;
/**
 *  @brief 获取GIF的帧显示时长数组。
 *  @param gifData GIF图片数据源
 *  @return 帧显示时长数组
 */
+ (NSArray<NSNumber*> *)delayArrayWithGifData:(NSData *)gifData;
/**
 *  @brief 获取GIF的指定帧图像。
 *  @param gifData GIF图片数据源
 *  @param index   帧索引
 *  @return 帧图像
 */
+ (UIImage *)imageWithGifData:(NSData *)gifData andIndex:(size_t)index;
/**
 *  @brief 获取GIF的帧图片数组。
 *  @param gifData GIF图片数据源
 *  @return 帧图像数组
 */
+ (NSArray<UIImage*> *)imageArrayWithGifData:(NSData *)gifData;
@end
