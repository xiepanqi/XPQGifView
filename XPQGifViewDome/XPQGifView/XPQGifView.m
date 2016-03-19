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
@property (nonatomic, assign) BOOL isRun;
@property (nonatomic, assign) size_t frameIndex;
@end

@implementation XPQGifView

-(instancetype)init {
    self = [super init];
    if (self) {
        [self configSelf];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configSelf];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (void)configSelf {
    _loopCount = NSUIntegerMax;
    _frameIndex = 0;
}

- (void)loadGifData:(NSData *)data {
    if (_isRun) {
        return;
    }
    else {
        _isRun = YES;
    }
    self.image = [UIImage imageWithData:data];
    __weak XPQGifView *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);
        if (src) {
            size_t frameCount = CGImageSourceGetCount(src);
            while (weakSelf.isRun) {
                NSDate *beginTime = [NSDate date];
                NSTimeInterval frameDelay = [weakSelf delayTimeWithSource:src andIndex:weakSelf.frameIndex];
                weakSelf.frameIndex ++;
                if (weakSelf.frameIndex == frameCount) {
                    weakSelf.frameIndex = 0;
                    if (weakSelf.loopCount != NSUIntegerMax) {
                        weakSelf.loopCount --;
                    }
                }
                UIImage *image = [weakSelf imageWithSource:src andIndex:weakSelf.frameIndex];
                [NSThread sleepUntilDate:[beginTime dateByAddingTimeInterval:frameDelay]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.image = image;
                });
            }
            CFRelease(src);
            weakSelf.isRun = NO;
        }
    });
}

-(void)stop {
    _isRun = NO;
    _frameIndex = 0;
    
}

-(UIImage *)imageWithSource:(CGImageSourceRef)src andIndex:(size_t)index {
    CGImageRef cgImg = CGImageSourceCreateImageAtIndex(src, index, NULL);
    UIImage *image = [UIImage imageWithCGImage:cgImg];
    CGImageRelease(cgImg);
    return image;
}

-(NSTimeInterval)delayTimeWithSource:(CGImageSourceRef)src andIndex:(size_t)index {
    NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, index, NULL));
    NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFDelayTime];
    return delayTime.floatValue;
}
@end
