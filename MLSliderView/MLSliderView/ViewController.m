//
//  ViewController.m
//  MLSliderView
//
//  Created by Alan.Dai on 2018/11/12.
//  Copyright © 2018 ML Day. All rights reserved.
//

#import "ViewController.h"
#import "MLSliderView.h"

@interface ViewController ()
@property (nonatomic, strong) MLSliderView *sliderView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor blackColor];
    
    self.sliderView = [[MLSliderView alloc] initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, 30)];
    [self.view addSubview:self.sliderView];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tempProgress];
    });
    
}


// 测试代码
- (void)tempProgress{
    static float bufferflag = 0.1;
    static float valueflag = 0.015;
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.sliderView.bufferValue += bufferflag;
        self.sliderView.value += valueflag;
        
        if (self.sliderView.bufferValue >= 1.f) {
            self.sliderView.bufferValue = 1;
        }
        if (self.sliderView.value >= 1.f) {
            self.sliderView.value = 1;
            [timer invalidate];
        }
    }];
    
}


@end
