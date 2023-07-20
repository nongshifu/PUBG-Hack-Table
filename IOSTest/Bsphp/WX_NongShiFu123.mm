//
//  ViewController.m
//  BSPHPOC
//  BSPHP 魔改UDID 技术团队 十三哥工作室
//  承接软件APP开发 UDID定制 验证加密二改 PHP JS HTML5开发 辅助开发
//  WX:NongShiFu123 QQ350722326
//  Created by MRW on 2022/11/14.
//  Copyright © 2019年 xiaozhou. All rights reserved.
//
#import <SystemConfiguration/SystemConfiguration.h>
#import "Config.h"
#import "WX_NongShiFu123.h"
#import <UIKit/UIKit.h>
#import "getKeychain.h"
#import "Config.h"
#import "SCLAlertView.h"
#import "MBProgressHUD+NJ.h"
#import <dlfcn.h>
#include <stdio.h>
#import <string.h>

#import <AdSupport/ASIdentifierManager.h>
@interface WX_NongShiFu123 ()

@end
NSString*验证信息;
bool 验证状态;
NSString*设备特征码;
NSString*到期时间;
@implementation WX_NongShiFu123

/*
 逻辑
 1.启动APP
 2.取getBSphpSeSsL
 3.读取描述 判断哪种 机器码方式UDID/IDFV 读取 弹窗类型 版本 公告 开关
 4.开始验证
 5.定时读取登录状态 -并且读取版本更新-公告更新
 */

+ (void)load {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[WX_NongShiFu123 alloc] BSPHP];
    });
        
}

#pragma mark --- 验证流程

- (void)BSPHP{
    NSString*km=[[NSUserDefaults standardUserDefaults] objectForKey:@"km"];
    [[WX_NongShiFu123 alloc] yanzhengAndUseIt:km];
}


#pragma mark ---获取本次打开的BSphpSeSsL 作为在线判断



#pragma mark --- 验证使用

- (void)yanzhengAndUseIt:(NSString*)km{
    //参数开始组包
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSString *appsafecode = [self getSystemDate];//设置一次过期判断变量
    param[@"api"] = @"login.ic";
    param[@"BSphpSeSsL"] = [self getSystemDate];//ssl是获取的全局参数，多开控制
    param[@"date"] = [self getSystemDate];
    param[@"md5"] = @"";
    param[@"mutualkey"] = BSPHP_MUTUALKEY;
    param[@"icid"] = km;
    param[@"icpwd"] = @"";
    param[@"key"] = [self getUDID];//绑定的机器码
    param[@"maxoror"] = [self getUDID];//绑定的机器码
    param[@"appsafecode"] = appsafecode;//这里是防封包被劫持的验证，传什么给服务器返回什么，返回不一样说明中途被劫持了
    [NetTool Post_AppendURL:BSPHP_HOST parameters:param success:^(id responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (dict) {
            //这里是防封包被劫持的验证，传什么给服务器返回什么，返回不一样说明中途被劫持了
            if(![dict[@"response"][@"appsafecode"] isEqualToString:appsafecode]){
                MyLog(@"2");
                dict[@"response"][@"data"] = @"-2000";
                验证状态=NO;
                验证信息=@"封包被劫持";
            }
            
            NSString *dataString = dict[@"response"][@"data"];
            NSRange range = [dataString rangeOfString:@"|1081|"];
            if (range.location != NSNotFound) {
                //验证成功
                NSArray *arr = [dataString componentsSeparatedByString:@"|"];
                if (arr.count >= 6)
                {
                    MyLog(@"验证成功=%@",dataString);
                    
                    NSString*fuwuqijqm=arr[2];
                    if ([fuwuqijqm containsString:[self getUDID]]) {
                        [[NSUserDefaults standardUserDefaults] setObject:km forKey:@"km"];
                        if ([dataString containsString:@"王"] || [dataString containsString:@":"] || ![dataString containsString:@":"]) {
                            验证状态=NO;
                        }
                        到期时间=arr[4];
                        验证状态=YES;
                    }else{
                        验证状态=NO;
                        验证信息=@"绑定机器码非本机";
                    }
                    
                }
            }else{
                验证信息=dataString;
                验证状态=NO;
                
            }
        }
    } failure:^(NSError *error) {
        验证信息=@"验证错误";
        验证状态=NO;
    }];
    
}

#pragma mark ---获取时间
- (NSString *)getSystemDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans_CN"];
    dateFormatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    [dateFormatter setDateFormat:@"yyyy-MM-dd#HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    return dateStr;
}

#pragma mark --- 获取UDID码

- (NSString*)getUDID
{
    static CFStringRef (*$MGCopyAnswer)(CFStringRef);
    void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY);
    $MGCopyAnswer = reinterpret_cast<CFStringRef (*)(CFStringRef)>(dlsym(gestalt, "MGCopyAnswer"));
    设备特征码=(__bridge NSString *)$MGCopyAnswer(CFSTR("SerialNumber"));
    if (设备特征码.length>6 ) {
        return 设备特征码;
    }else{
        return @"null";
    }
    
    
}


@end
