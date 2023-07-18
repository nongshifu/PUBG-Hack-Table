//
//  ImGuiDrawView.h
//  ImGuiTest
//
//  Created by 十三哥 on 2023/6/27.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ImGuiMem.h"
#import "ZhuBiaoGe.h"
#import "TableViewController.h"

@interface ImGuiMem ()

@end


@implementation ImGuiMem

+ (instancetype)sharedInstance {
    static ImGuiMem *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame=CGRectMake(kWidth/2-400/2, kHeight/2-菜单高度/2, 菜单宽度, 菜单高度);
        // 设置圆角半径
        self.subviews.firstObject.layer.cornerRadius = 10.0;
        self.subviews.firstObject.layer.masksToBounds = YES; // 剪裁超出边界的部分
        // 设置边框宽度和颜色
        self.subviews.firstObject.layer.borderWidth = 2.0;//设置边框宽度
        self.subviews.firstObject.layer.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor;//边框透明色 不描边
        self.subviews.firstObject.backgroundColor=[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7];//背景色为半透明
        self.subviews.firstObject.frame=self.bounds;
        //设置果过直播状态
        self.secureTextEntry=YES;
        // 禁用键盘响应
        self.userInteractionEnabled = YES;
        self.subviews.firstObject.userInteractionEnabled = YES;
        [self csh];
        [self mem];
        
    }
    return self;
}
-(void)csh{
   
    
    //捆绑拖动手势到视图=======
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(movingBtn:)];
    [self addGestureRecognizer:pan];
    
    // 创建一个捏合手势识别器========
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    // 将捏合手势识别器添加到视图中
    [self addGestureRecognizer:pinchGesture];
}

-(void)mem{
    
    //加载主菜单表格视图
    ZhuBiaoGe *memTableVC = [ZhuBiaoGe sharedInstance];
    memTableVC.view.frame=CGRectMake(10, 顶头间隔+10, self.bounds.size.width-20, self.bounds.size.height-顶头间隔-20);
    [self.subviews.firstObject addSubview:memTableVC.view];
    
    UIView*logo=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];//顶头logo Hello, world! 高度
    logo.backgroundColor=[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    // 创建一个 logo
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 菜单宽度, 40)];
    // 设置文字
    myLabel.text = @"Hello, world!";
    // 设置字体大小和颜色
    myLabel.font = [UIFont systemFontOfSize:25];
    myLabel.textColor = [UIColor redColor];//颜色
    myLabel.textAlignment = NSTextAlignmentCenter;//居中
    // 将 UILabel 添加到视图中
    [logo addSubview:myLabel];
    [self.subviews.firstObject addSubview:logo];
    

}

//禁用键盘
- (BOOL)canBecomeFirstResponder {
    return NO;
}


//拖动手势方法
- (void)movingBtn:(UIPanGestureRecognizer *)recognizer{
    UIView *view = recognizer.view;
    CGPoint translation = [recognizer translationInView:view];
    if(recognizer.state == UIGestureRecognizerStateBegan){
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:view];
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        float newX2=view.center.x;
        float newY2=view.center.y;
        
        view.center = CGPointMake(newX2 , newY2 );
        [recognizer setTranslation:CGPointZero inView:view];
    }
    //黏边效果
    
    [UIView animateWithDuration:0.5 animations:^{
        //超出屏幕左边
        if (view.frame.origin.x<0) {
            view.frame=CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        }
        //超出屏幕上面
        if (view.frame.origin.y<0) {
            view.frame=CGRectMake(view.frame.origin.x, 0, view.frame.size.width, view.frame.size.height);
        }
        //超出屏幕底部
        if (view.frame.origin.y+view.frame.size.height>kHeight) {
            view.frame=CGRectMake(view.frame.origin.x, kHeight-view.frame.size.height, view.frame.size.width, view.frame.size.height);
        }
        //超出屏幕右边
        if (view.frame.origin.x+view.frame.size.width>kWidth) {
            view.frame=CGRectMake(kWidth-view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        }
        
    }];
    
}

// 处理捏合放大缩小手势
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        // 缩放视图
        view.transform = CGAffineTransformScale(view.transform, gesture.scale, gesture.scale);
        gesture.scale = 1.0;
    }
}
@end


