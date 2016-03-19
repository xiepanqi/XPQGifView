//
//  XPQGifView.m
//  XPQGifViewDome
//
//  Created by 谢攀琪 on 16/3/19.
//  Copyright © 2016年 谢攀琪. All rights reserved.
//

#import "XPQGifView.h"
#import <ImageIO/ImageIO.h>

@interface XPQGifView ()
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) size_t frameIndex;
/// 标识图片资源是否改变。
@property (nonatomic, assign) BOOL isSourceChange;
@end

@implementation XPQGifView
#pragma mark - 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (instancetype)initWithGifData:(NSData *)gifData {
    self = [super init];
    if (self) {
        [self configSelf];
        self.gifData = gifData;
    }
    return self;
}

- (void)configSelf {
    _isPlay = NO;
    _loopCount = NSUIntegerMax;
    _frameIndex = 0;
    _sleep = 1.0;
}

#pragma mark - 属性
- (void)setGifData:(NSData *)gifData {
    if (_gifData == gifData) {
        return;
    }
    _gifData = gifData;
    _isSourceChange = YES;
    _frameIndex = 0;
    self.image = [UIImage imageWithData:_gifData];
}

#pragma mark - 操作
-(void)start {
    [self playGifAnimation];
}

-(void)suspend {
    _isPlay = NO;
}

-(void)stop {
    _isPlay = NO;
    _frameIndex = 0;
    self.image = [UIImage imageWithData:_gifData];
}

#pragma mark - gif播发代码
- (void)playGifAnimation {
    if (_isPlay) {
        return;
    }
    else {
        _isPlay = YES;
    }
    __weak XPQGifView *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageSourceRef src = nil;
        size_t frameCount = 0;
        while (weakSelf.isPlay) {
            NSDate *beginTime = [NSDate date];
            // gifData改变或者线程刚开始src为nil，并且要gifData有数据
            if ((weakSelf.isSourceChange || src == nil) && weakSelf.gifData != nil) {
                weakSelf.isSourceChange = NO;
                if (src) {
                    CFRelease(src);
                }
                src = CGImageSourceCreateWithData((__bridge CFDataRef)weakSelf.gifData, NULL);
                if (src) {
                    frameCount = CGImageSourceGetCount(src);
                }
                else {
                    return;
                }
            }
            
            NSTimeInterval frameDelay = [weakSelf delayTimeWithSource:src andIndex:weakSelf.frameIndex];
            frameDelay *= weakSelf.sleep;
            weakSelf.frameIndex ++;
            if (weakSelf.frameIndex == frameCount) {
                weakSelf.frameIndex = 0;
                if (weakSelf.loopCount != NSUIntegerMax) {
                    weakSelf.loopCount --;
                }
            }
            CGImageRef cgImg = CGImageSourceCreateImageAtIndex(src, weakSelf.frameIndex, NULL);
            UIImage *image = [UIImage imageWithCGImage:cgImg];
            CGImageRelease(cgImg);
            // 使用下面一句替换上面三句的话，在Release模式下内存暴涨
//            UIImage *image = [weakSelf imageWithSource:src andIndex:weakSelf.frameIndex];
            [NSThread sleepUntilDate:[beginTime dateByAddingTimeInterval:frameDelay]];
            dispatch_sync(dispatch_get_main_queue(), ^{  // 使用异步的话有小概率出现问题
                if (weakSelf.isPlay && !weakSelf.isSourceChange) {
                    weakSelf.image = image;
                }
            });
        }
        if (src) {
            CFRelease(src);
        }
        weakSelf.isPlay = NO;
    });
}

/// 获取gif指定帧图像，在Release模式下内存暴涨，但使用Leaks检测内存并没有泄漏
-(UIImage *)imageWithSource:(CGImageSourceRef)src andIndex:(size_t)index {
    CGImageRef cgImg = CGImageSourceCreateImageAtIndex(src, index, NULL);
    UIImage *image = [UIImage imageWithCGImage:cgImg];
    CGImageRelease(cgImg);
    return image;
}

/// 获取gif指定帧持续时间，好像有内存泄漏，不过用Leaks检测不出
-(NSTimeInterval)delayTimeWithSource:(CGImageSourceRef)src andIndex:(size_t)index {
    CGFloat frameDelay = 0.0;
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(src, index, NULL);
    CFDictionaryRef frameProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
    CFNumberRef delayTime = CFDictionaryGetValue(frameProperties, kCGImagePropertyGIFDelayTime);
    CFNumberGetValue(delayTime, kCFNumberFloat64Type, &frameDelay);
    if (properties) {
        CFRelease(properties);
    }
    return frameDelay;
}
@end
