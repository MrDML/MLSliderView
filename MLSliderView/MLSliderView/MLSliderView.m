//
//  MLSliderView.m
//  MLSliderView
//
//  Created by Alan.Dai on 2018/11/12.
//  Copyright © 2018 ML Day. All rights reserved.
//

#import "MLSliderView.h"

// 滑块的大小
static const CGFloat kSliderBtnWH = 19.0;
// 间距
static const CGFloat kProgressMargin = 2;
// 进度的高度
static const CGFloat kProgressH = 2.0;
// 拖动slider动画的时间
static const CGFloat kAnimate = 0.3;


@interface MLSliderButton : UIButton

@end

@implementation MLSliderButton

// 重写此方法扩大按钮的点击范围
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect bounds = self.bounds;
    
    /*
     摘要
     
     返回一个小于或大于源矩形的矩形，具有相同的中心点。
     宣言
     
     CGRect CGRectInset（CGRect rect，CGFloat dx，CGFloat dy）;
     讨论
     
     矩形是标准化的，然后应用插入参数。如果生成的矩形具有负高度或宽度，则返回空矩形。
     参数
     
     矩形
     源CGRect结构。
     DX
     用于调整源矩形的x坐标值。要创建插入矩形，请指定正值。要创建更大的包含矩形，请指定负值。
     DY
     用于调整源矩形的y坐标值。要创建插入矩形，请指定正值。要创建更大的包含矩形，请指定负值。
     返回
     
     一个矩形。原点值在x轴上偏移由dx参数指定的距离，在y轴上偏移由dy参数指定的距离，其大小由（2 * dx，2 * dy）调整，相对于源矩形。如果dx和dy是正值，则矩形的大小会减小。如果dx和dy为负值，则矩形的大小会增加。
     在Developer Documentation中打开
     */
    CGRect rect = CGRectInset(bounds, -20, -20);
    
    return CGRectContainsPoint(rect, point);
    
    
}


@end

@interface MLSliderView ()

// 进度背景
@property (nonatomic, strong) UIImageView *bgProgressView;
// 缓存进度
@property (nonatomic, strong) UIImageView *bufferProgressView;
// 滑杆进度
@property (nonatomic, strong) UIImageView *sliderProgressView;
// 滑块
@property (nonatomic, strong) MLSliderButton *sliderBtn;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;


@end


@implementation MLSliderView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.allowTapped = YES;
        self.animate = YES;
        [self addSubViews];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.allowTapped = YES;
    self.animate = YES;
    [self addSubViews];
}


// 添加子视图
- (void)addSubViews{
    
    // 添加控件
    [self addSubview:self.bgProgressView];
    [self addSubview:self.bufferProgressView];
    [self addSubview:self.sliderProgressView];
    [self addSubview:self.sliderBtn];
    
    
    // 设置控件frame
    self.bgProgressView.frame = CGRectMake(kProgressMargin, 0, 0, kProgressH);

    self.sliderProgressView.frame = self.bgProgressView.frame;
    self.bufferProgressView.frame = self.bgProgressView.frame;
    self.sliderBtn.frame = CGRectMake(0, 0, kSliderBtnWH, kSliderBtnWH);
    
    
    // 添加点击手势
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tapGesture];
    
    // 添加滑动手势
    UIPanGestureRecognizer *panGesture  = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderGesture:)];
    [self addGestureRecognizer:panGesture];
    
}




- (void)layoutSubviews{
    [super layoutSubviews];
    
    
    if (self.sliderBtn.hidden) {
        
        CGRect rect = self.bgProgressView.frame;
        rect.size.width = self.frame.size.width;
        self.bgProgressView.frame = rect;
    
    }else{
        CGRect rect = self.bgProgressView.frame;
        rect.size.width = self.frame.size.width - kProgressMargin * 2;
        self.bgProgressView.frame = rect;
    }
    
    
    CGPoint bgPoint = self.bgProgressView.center;
    bgPoint.y = self.frame.size.height * 0.5;
    self.bgProgressView.center = bgPoint;
    
    CGPoint buffPoint = self.bufferProgressView.center;
    buffPoint.y = self.frame.size.height * 0.5;
    self.bufferProgressView.center = bgPoint;
    
    CGPoint sliderPoint = self.sliderProgressView.center;
    sliderPoint.y = self.frame.size.height * 0.5;
    self.sliderProgressView.center = sliderPoint;
    
    CGPoint sliderBtnPoint = self.sliderBtn.center;
    sliderBtnPoint.y = self.frame.size.height * 0.5;
    self.sliderBtn.center = sliderBtnPoint;
    
    
    // 修复 slider bufferProgress 错位问题
    CGFloat finishValue = self.bgProgressView.frame.size.width * self.bufferValue;
    CGRect buffRect = self.bufferProgressView.frame;
    buffRect.origin.x = self.bgProgressView.frame.origin.x;
    buffRect.size.width = finishValue;
    self.bufferProgressView.frame = buffRect;


    CGFloat progressValue = self.bgProgressView.frame.size.width * self.value;
    CGRect sliderRect = self.sliderProgressView.frame;
    sliderRect.origin.x = self.bgProgressView.frame.origin.x;
    sliderRect.size.width = progressValue;
    self.sliderProgressView.frame = sliderRect;
    
    
    CGRect sliderBtnRect = self.sliderBtn.frame;
    sliderBtnRect.origin.x = (self.frame.size.width - self.sliderBtn.frame.size.width) * self.value;
    self.sliderBtn.frame = sliderBtnRect;
    
    
   
}


// 点击事件
- (void)tapped:(UITapGestureRecognizer *)tapGesture{
    
    CGPoint locationPoint = [tapGesture locationInView:self];
    
    CGFloat totalWidth = self.bgProgressView.frame.size.width;
    CGFloat offsetX = (locationPoint.x - self.bgProgressView.frame.origin.x)*1.0;
    
    CGFloat value = offsetX / totalWidth;
    
    // value 不能超过1
    value = value >= 1.f ? 1 : value <= 0.f ? 0: value;
    [self setValue:value];
    if ([self.delegate respondsToSelector:@selector(sliderTapped:)]) {
        [self.delegate sliderTapped:value];
    }
}


- (void)sliderGesture:(UIPanGestureRecognizer *)panGesture{
    
    UIGestureRecognizerState state = panGesture.state;
    
    if (state == UIGestureRecognizerStateBegan) {
        [self sliderBeganTouchBtn:self.sliderBtn];
    }else if (state == UIGestureRecognizerStateChanged){
       
        [self sliderDraggingBtn:[panGesture locationInView:self]];
    }else if (state == UIGestureRecognizerStateEnded){
         [self sliderEndTouchBtn:self.sliderBtn];
        
    }
    
    
    
}

// 开始拖动
- (void)sliderBeganTouchBtn:(UIButton *)sender{

    if ([self.delegate respondsToSelector:@selector(sliderTouchBegan:)]) {
        [self.delegate sliderTouchBegan:self.value];
    }
    
    // 开始拖动的时候有一个放大的操作
    [UIView animateWithDuration:kAnimate animations:^{
        sender.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
    
}

// 拖动结束
- (void)sliderEndTouchBtn:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(sliderEndTouchBtn:)]) {
        [self.delegate sliderTouchEnd:self.value];
    }
    [UIView animateWithDuration:kAnimate animations:^{
        sender.transform = CGAffineTransformIdentity;
    }];
}



- (void)sliderDraggingBtn:(CGPoint )point{
    
    CGFloat totalWidth = self.frame.size.width - self.sliderBtn.frame.size.width;
    CGFloat offsetX = (point.x - self.sliderBtn.frame.size.width * 0.5) * 1.0;
    // 获取进度值 由于btn是从 0-(self.width - btn.width)
    CGFloat value = offsetX/totalWidth;
    // value的值需在0-1之间
    value = value >= 1.f ? 1 : value <= 0.f ? 0: value;
    
    
    self.isForward = self.value < value;
    
    [self setValue:value];
    
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:value];
    }
    
    
}


#pragma mark Setter


- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor{
    _maximumTrackTintColor = maximumTrackTintColor;
    self.bgProgressView.backgroundColor = maximumTrackTintColor;
}


- (void)setMinimunTrackTintColor:(UIColor *)minimunTrackTintColor{
    _minimunTrackTintColor = minimunTrackTintColor;
    self.sliderProgressView.backgroundColor = minimunTrackTintColor;
}

- (void)setBufferTrackTintcolor:(UIColor *)bufferTrackTintcolor{
    _bufferTrackTintcolor = bufferTrackTintcolor;
    self.bufferProgressView.backgroundColor = bufferTrackTintcolor;
}



- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage{
    _maximumTrackImage = maximumTrackImage;
    self.bgProgressView.image = maximumTrackImage;
    self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage{
    _minimumTrackImage = minimumTrackImage;
    self.sliderProgressView.image = minimumTrackImage;
    self.minimunTrackTintColor = [UIColor clearColor];
}

- (void)setBufferTrackImage:(UIImage *)bufferTrackImage{
    _bufferTrackImage = bufferTrackImage;
    self.bufferProgressView.image = bufferTrackImage;
    self.bufferProgressView.backgroundColor = [UIColor clearColor];
}

- (void)setBufferValue:(float)bufferValue{
    _bufferValue = bufferValue;
    
    CGFloat bufferWidth = self.bgProgressView.frame.size.width * bufferValue;
    CGRect rect = self.bufferProgressView.frame;
    rect.size.width = bufferWidth;
    self.bufferProgressView.frame = rect;
}

- (void)setValue:(float)value{
    _value = value;
    
    CGFloat sliderBtnTotalWidth = self.frame.size.width - self.sliderBtn.frame.size.width;
    
    CGRect sliderBtnRect = self.sliderBtn.frame;
    sliderBtnRect.origin.x = sliderBtnTotalWidth * value;
    self.sliderBtn.frame = sliderBtnRect;
    
    CGRect sliderRect = self.sliderProgressView.frame;
    sliderRect.size.width = (self.frame.size.width - 2 * kProgressMargin) * value;
    self.sliderProgressView.frame = sliderRect;
    
    self.lastPoint = self.sliderBtn.center;
    
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state{
    [self.sliderBtn setBackgroundImage:image forState:state];
    [self.sliderBtn sizeToFit];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state{
    [self.sliderBtn setImage:image forState:state];
    [self.sliderBtn sizeToFit];
}

- (void)setAllowTapped:(BOOL)allowTapped{
    _allowTapped = allowTapped;
    if (!allowTapped) {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

- (void)setSliderHeight:(CGFloat)sliderHeight{
    _sliderHeight = sliderHeight;
    
    CGRect bgRect = self.bgProgressView.frame;
    bgRect.size.height = sliderHeight;
    self.bgProgressView.frame = bgRect;
    
    CGRect buffRect = self.bufferProgressView.frame;
    buffRect.size.height = sliderHeight;
    self.bufferProgressView.frame = buffRect;
    
    CGRect sliderRect = self.self.sliderProgressView.frame;
    sliderRect.size.height = sliderHeight;
    self.sliderProgressView.frame = sliderRect;

}


- (void)setIsHideSliderBlock:(BOOL)isHideSliderBlock{
    _isHideSliderBlock = isHideSliderBlock;
    // 隐藏滑块，滑杆不隐藏
    if (isHideSliderBlock) {
        self.sliderBtn.hidden = YES;
        CGRect bgRect = self.bgProgressView.frame;
        bgRect.origin.x = 0;
//        bgRect.size.width = self.frame.size.width;
        self.bgProgressView.frame = bgRect;
        
        CGRect buffRect = self.bufferProgressView.frame;
        buffRect.origin.x = 0;
//        buffRect.size.width = self.frame.size.width;
        self.bufferProgressView.frame = buffRect;
        
        CGRect sliderRect = self.self.sliderProgressView.frame;
        sliderRect.origin.x = 0;
//        sliderRect.size.width = self.frame.size.width;
        self.sliderProgressView.frame = sliderRect;
        
    }
}


#pragma mark Getter
- (UIView *)bgProgressView{
    if (!_bgProgressView) {
        _bgProgressView = [[UIImageView alloc] init];
        _bgProgressView.backgroundColor = [UIColor grayColor];
        _bgProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bgProgressView.clipsToBounds = YES;
    }
    
    return _bgProgressView;
}

- (UIView *)sliderProgressView{
    if (!_sliderProgressView) {
        _sliderProgressView = [[UIImageView alloc] init];
        _sliderProgressView.backgroundColor = [UIColor redColor];
        _sliderProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _sliderProgressView.clipsToBounds = YES;
    }
    return _sliderProgressView;
}


- (UIView *)bufferProgressView{
    if (!_bufferProgressView) {
        _bufferProgressView = [[UIImageView alloc] init];
        _bufferProgressView.backgroundColor = [UIColor whiteColor];
        _bufferProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bufferProgressView.clipsToBounds = YES;
    }
     return _bufferProgressView;
    
}


- (MLSliderButton *)sliderBtn{
    if (!_sliderBtn) {
        _sliderBtn = [MLSliderButton buttonWithType:UIButtonTypeCustom];
        _sliderBtn.backgroundColor = [UIColor blueColor];
        [_sliderBtn setAdjustsImageWhenDisabled:YES];
    }
    return _sliderBtn;
}



@end
