# XPQGifView
## 实现目的
现在显示gif动态图大部分都是把所有帧加载到`UIImageView`的`animationImages`里面或者使用`UIWebView`显示。这两种方法使用`UIImageView`的`animationImages`会占用大量内存，而使用`UIWebView`不但内存占用更多，还要占用CPU资源，相比使用`UIImage`得不偿失。为了解决gif显示资源的占用问题特地写了这个gif显示view。
  
## 性能对比
在Dome里面的GIF图分辨率是400*225/81帧。**（5S真机测试，模拟器性能会有不同）**

使用`UIImageView`把所有帧都加载到`animationImages`内存会暴涨到35+M以上。

![UIImageView显示](http://img.blog.csdn.net/20160410110848764)

  使用`UIWebView`占用的内存更多，而且还要占用一定CPU资源。
  
  ![UIWebView显示](http://img.blog.csdn.net/20160410112456337)
  
  使用`XPQGifView`需要同时占用CPU和内存，占用比可以调节，可以更具使用环境来确定。下图是内存占用率最低的状态。
  
  ![XPQGifView显示](http://img.blog.csdn.net/20160410112937167)

## 实现原理
实现原理其实很简单，就是不把解析出来的图片保存到内存中，而是事实解析，所以内存占用率很低，但会占用一定的CPU。虽然性能分析上CPU占用率高达8%，但其实这8%的很大部分时间是用在sleep上，如果同时显示多个gif图CPU占用率并不会有多大的提升。
CPU占用率调节则是把一定的帧图像保存到内存中，这样CPU的占用率就会降低，不过内存占用率会增加。

## 使用
该视图继承自`UIImageView`。很多父属性都是可用的。
### 初始化
禁用了`UIImageView`的`initWithImage:`和`initWithImage:highlightedImage:`两个初始化方法。
另外增加了`initWithGifData:`和`initWithGifData:andLoopCount:`两个初始化方法。

使用时先把gif图加载成`NSData`类型，再初始化`XPQGifView`，也可以使用`UIImageView`的其他方法初始化，然后修改`gifData`和`loopCount`属性。

### 属性
`isPlay` 只读，是否在播发。
`loopCount` 重复播发次数。可以在播发过程中修改，但修改后前面播发的次数还算。
`gifData` gif数据源。可以在播发过程中修改。修改后从第一帧开始播发，并且前面播发的次数还算。
`sleep` 播发速度。越大播发速度越慢，越小越快。实际播发速度＝原播发速度*sleep。默认1.0。
`frameCacheInterval` 内存占比。默认NSUIntegerMax。该值表示隔多少帧保存一次缓存，为0表示全部保存，大于frameCount全部不保存。 值越小占用内存越大，消耗CPU越小。修改此值必须要动画下次启动才生效。此值根据实际使用情况来设置。

### 方法
`- (void)start;`
启动无限播发GIF，如果gifData为nil则不做任何操作。

`- (void)startLoopCount:(NSUInteger)loopCount;`
指定次数播发GIF，如果gifData为nil则不做任何操作。`loopCount` 为重复播发次数

`- (void)suspend;`
暂停播发GIF，再次使用start时从暂停的帧开始播发。

`- (void)stop;`
停止播发GIF，再次使用start时从第一帧开始播发。

### 类方法
有4个类方法，分别是获取帧的图像和显示时长。
`+ (NSTimeInterval)delayTimeWithGifData:(NSData *)gifData andIndex:(size_t)index;`
`+ (NSArray<NSNumber*> *)delayArrayWithGifData:(NSData *)gifData;`
`+ (UIImage *)imageWithGifData:(NSData *)gifData andIndex:(size_t)index;`
`+ (NSArray<UIImage*> *)imageArrayWithGifData:(NSData *)gifData;`
