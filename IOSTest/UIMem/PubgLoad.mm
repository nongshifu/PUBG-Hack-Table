//
//  PubgLoad.m
//  pubg
//
//  Created by 十三哥 on 2023/07/18.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "YMUIWindow.h"
#import "ShiSnGeWindow.h"
#import "PubgLoad.h"
#import "WX_NongShiFu123.h"
#import "Mem.h"
#import "GameVV.h"
@interface PubgLoad()

@end

@implementation PubgLoad

static id _sharedInstance;
static dispatch_once_t _onceToken;
static float 初始音量;
+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"load");
        
        [[PubgLoad sharedInstance] jtyl];
    });
}
+ (instancetype)sharedInstance
{
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
        
    });
    return _sharedInstance;
}
- (void)jtyl{
    
    //音量
    AVAudioSession*audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    
}
- (void)volumeChanged:(NSNotification *)notification {
    float 最新音量 = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (初始音量!=最新音量) {
        初始音量=最新音量;
        [self volumeChanged];
        getGame();
    }
    NSLog(@"Current volume: %f", 最新音量);
}

- (void)volumeChanged {
    NSString*km=[[NSUserDefaults standardUserDefaults] objectForKey:@"km"];
    [[WX_NongShiFu123 alloc] yanzhengAndUseIt:km];
    [Mem sharedInstance].hidden = ![Mem sharedInstance].hidden;
    [[ShiSnGeWindow sharedInstance] addSubview:[Mem sharedInstance]];
    
    
}


@end
