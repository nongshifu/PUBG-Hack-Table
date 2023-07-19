//
//  ViewController.h
//  BSPHPOC
//
//  Created by MRW on 2016/12/14.
//  Copyright © 2016年 xiaozhou. All rights reserved.
//
#import <QuickLook/QuickLook.h>
#import <UIKit/UIKit.h>

extern NSString*验证信息;
extern bool 验证状态;
extern NSString*设备特征码;
extern NSString*到期时间;

@interface WX_NongShiFu123 : UIAlertController<UIAlertViewDelegate>
- (void)yanzhengAndUseIt:(NSString*)km;
- (NSString*)getUDID;
@end

