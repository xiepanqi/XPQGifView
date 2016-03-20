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
/// 还剩余的播发次数。
@property (nonatomic, assign) NSUInteger lastCount;

/// 保存帧播发间隔时间。因为播发间隔数据量不大就全部保存下来，减少CPU开销。
@property (nonatomic, strong) NSMutableArray<NSNumber*> *frameDelayArray;
/// 保存帧图片。因为图片数据量太大，内存消耗巨大，所以只保存部分，平衡内存和CPU的开销。
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, UIImage*> *imageCache;
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

- (instancetype)initWithGifData:(NSData *)gifData andLoopCount:(NSUInteger)loopCount {
    self = [super init];
    if (self) {
        [self configSelf];
        self.gifData = gifData;
        self.loopCount = loopCount;
    }
    return self;
}

- (void)configSelf {
    _isPlay = NO;
    _loopCount = NSUIntegerMax;
    _frameIndex = 0;
    _sleep = 1.0;
    _frameCacheInterval = NSUIntegerMax;
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
- (void)start {
    _lastCount = self.loopCount;
    [self playGifAnimation];
}

- (void)startLoopCount:(NSUInteger)loopCount {
    self.loopCount = loopCount;
    [self start];
}

- (void)suspend {
    _isPlay = NO;
}

- (void)stop {
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
        size_t frameCacheInterval = NSUIntegerMax;
        while (weakSelf.isPlay && weakSelf.lastCount > 0) {
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
                    weakSelf.frameDelayArray = [NSMutableArray array];
                    weakSelf.imageCache = [NSMutableDictionary dictionary];
                    if (weakSelf.frameCacheInterval != NSUIntegerMax) {
                        frameCacheInterval = weakSelf.frameCacheInterval + 1;
                    }
                }
                else {
                    break;
                }
            }
            
            NSTimeInterval frameDelay = 0.0;
            if (weakSelf.frameIndex < weakSelf.frameDelayArray.count) {
                frameDelay = weakSelf.frameDelayArray[weakSelf.frameIndex].floatValue;
            }
            else {
                frameDelay = [weakSelf delayTimeWithSource:src andIndex:weakSelf.frameIndex];
                [weakSelf.frameDelayArray addObject:@(frameDelay)];
            }
            frameDelay *= weakSelf.sleep;
            weakSelf.frameIndex ++;
            if (weakSelf.frameIndex == frameCount) {
                weakSelf.frameIndex = 0;
                if (weakSelf.lastCount != NSUIntegerMax) {
                    weakSelf.lastCount --;
                }
            }
            UIImage *image =  weakSelf.imageCache[@(weakSelf.frameIndex)];
            if (image == nil) {
                CGImageRef cgImg = CGImageSourceCreateImageAtIndex(src, weakSelf.frameIndex, NULL);
                image = [UIImage imageWithCGImage:cgImg];
                CGImageRelease(cgImg);
                // 使用下面一句替换上面三句的话，在Release模式下内存暴涨
//                image = [weakSelf imageWithSource:src andIndex:weakSelf.frameIndex];
                if (frameCacheInterval < frameCount
                    && weakSelf.frameIndex % frameCacheInterval == 0) {
                    weakSelf.imageCache[@(weakSelf.frameIndex)] = image;
                }
            }
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
