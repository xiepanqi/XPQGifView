//
//  XPQGifView.h
//  XPQGifViewDome
//
//  Created by 谢攀琪 on 16/3/19.
//  Copyright © 2016年 谢攀琪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XPQGifView : UIImageView

- (instancetype)initWithImage:(UIImage *)image UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage UNAVAILABLE_ATTRIBUTE;

@property (nonatomic, assign, readonly) BOOL isRun;

@property (nonatomic, assign) NSUInteger loopCount;

- (void)loadGifData:(NSData *)data;
- (void)stop;
@end
