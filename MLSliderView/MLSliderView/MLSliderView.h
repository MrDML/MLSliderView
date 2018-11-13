//
//  MLSliderView.h
//  MLSliderView
//
//  Created by Alan.Dai on 2018/11/12.
//  Copyright © 2018 ML Day. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MLSliderViewDelegate <NSObject>

@optional

// 滑块开始滑动
- (void)sliderTouchBegan:(float)value;
// 滑块滑动中
- (void)sliderValueChanged:(float)value;
// 滑块结束滑动
- (void)sliderTouchEnd:(float)value;
// 滑杆点击
- (void)sliderTapped:(float)value;

@end

@interface MLSliderView : UIView

@property (nonatomic, weak) id<MLSliderViewDelegate>delegate;

// 默认滑竿的颜色
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
// 滑杆进度颜色
@property (nonatomic, strong) UIColor *minimunTrackTintColor;
// 缓冲进度颜色
@property (nonatomic, strong) UIColor *bufferTrackTintcolor;

// 默认滑杆的图片
@property (nonatomic, strong) UIImage *maximumTrackImage;
// 滑杆进度的图片
@property (nonatomic, strong) UIImage *minimumTrackImage;
// 缓存进度图片
@property (nonatomic, strong) UIImage *bufferTrackImage;

// 滑杆进度
@property (nonatomic, assign) float value;
// 缓存进度
@property (nonatomic, assign) float bufferValue;
// 是否允许点击,默认YES
@property (nonatomic, assign) BOOL allowTapped;
// 是否允许点击, 默认YES
@property (nonatomic, assign) BOOL animate;
// 滑杆的高度
@property (nonatomic, assign) CGFloat sliderHeight;
// 是否隐藏滑块 默认NO
@property (nonatomic, assign) BOOL isHideSliderBlock;
// 是否正在拖动
@property (nonatomic, assign) BOOL isdragging;
// 是否向前快进
@property (nonatomic, assign) BOOL isForward;

// 设置滑块背景色
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
// 设置滑块图片
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;


@end

NS_ASSUME_NONNULL_END
