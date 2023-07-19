//
//  PUBGDrawView.m
//  ChatsNinja
//
//  Created by TianCgg on 2022/10/2.
//

#import "GameData.h"
#import "GameVV.h"
#define kuandu  [UIScreen mainScreen].bounds.size.width
#define gaodu [UIScreen mainScreen].bounds.size.height
#define vvv @"6.0"
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <stdio.h>
#import <AVFoundation/AVFoundation.h>

@interface GameData()

@property (nonatomic, strong) dispatch_source_t timer1;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic, strong) dispatch_source_t timer3;

@end

static NSString*UDID;
static float currentVolume;



@implementation GameData
+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            GameData*vv=[[GameData alloc] init];
            UDID = [GameData getDeviceUDID];
            [vv jctime];
            
        });
    });
}

#pragma mark - 进程定时器
- (void)jctime {
    // 定时器1，每秒读取音量
    self.timer1 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.timer1, DISPATCH_TIME_NOW, 30.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer1, ^{
        [self getGameJC];
    });
    dispatch_resume(self.timer1);
    
    
}
#pragma mark - 读取数据定时器
- (void)shjutime {
    static NSMutableString*物资数据;
    static NSMutableString*敌人数据;
    //数据定时器
    self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 1.0/40 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer2, ^{
        敌人数据=[[GameVV factory] getData];
    });
    dispatch_resume(self.timer2);
    
    //物资定时器
    dispatch_queue_t wzQueue = dispatch_queue_create("com.example.wzQueue", DISPATCH_QUEUE_CONCURRENT);
    self.timer3 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, wzQueue);
    dispatch_source_set_timer(self.timer3, DISPATCH_TIME_NOW, 1.0/3 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer3, ^{
        [[GameVV factory] getNSArray];
       
        物资数据=[[GameVV factory] getwzData];
        
    });
    dispatch_resume(self.timer3);
}



#pragma mark - 读取游戏基础数据
-(bool)getGameJC{
    bool jc=getGame();
    if(jc==true) return true;
    // 取消定时器
    if (self.timer2) {
        dispatch_source_cancel(self.timer2);
        self.timer2 = nil;
    }
    // 取消定时器
    if (self.timer3) {
        dispatch_source_cancel(self.timer3);
        self.timer3 = nil;
    }
    
    return false;
}
#pragma mark - 其他函数
//获取IP地址
+(NSString*)getLocalIPAddress {
    NSString *localIP = nil;
    struct ifaddrs *addrs;
    if (getifaddrs(&addrs)==0) {
        const struct ifaddrs *cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
                {
                    localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                    break;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return localIP;
}
//获取设备UDID
+(NSString*)getDeviceUDID {
    CFStringRef (*$MGCopyAnswer)(CFStringRef);
    void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY);
    if (gestalt == NULL) {
        NSLog(@"Failed to load libMobileGestalt.dylib.");
        return nil;
    }
    $MGCopyAnswer = reinterpret_cast<CFStringRef (*)(CFStringRef)>(dlsym(gestalt, "MGCopyAnswer"));
    if ($MGCopyAnswer == NULL) {
        NSLog(@"Failed to find MGCopyAnswer function.");
        dlclose(gestalt);
        return nil;
    }
    NSString *udid = (__bridge NSString *)$MGCopyAnswer(CFSTR("SerialNumber"));
    dlclose(gestalt);
    return udid;
}
//拷贝剪贴板
+(void)copyURLToPasteboard:(NSString *)url {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:url];
}
//获取音量

@end
