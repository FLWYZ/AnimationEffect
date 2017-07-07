//
//  AEController.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "AEController.h"

static inline void __AEThreadSafeCall(void(^action)(void)) {
    dispatch_async(dispatch_get_main_queue(), action);
}

@interface AEController()

@property (strong, nonatomic) NSTimer *animationTimer;
@property (assign, nonatomic, readwrite) AEMode animationEffectMode;
@property (strong, nonatomic) NSMutableDictionary *animationDic;

@end

@implementation AEController

+ (instancetype)controller {
    static dispatch_once_t onceToken;
    static AEController *controller = nil;
    dispatch_once(&onceToken, ^{
        controller = [[AEController alloc] init];
    });
    return controller;
}

- (void)fireWithAEMode:(AEMode)animationEffectMode repeatTimeInterval:(NSTimeInterval)repeatTimeInterval{
    __AEThreadSafeCall(^{
        if (_animationTimer == nil) {
            _animationEffectMode = animationEffectMode;
            _animationTimer = [NSTimer scheduledTimerWithTimeInterval:repeatTimeInterval <= 0 ? AEDefaultTimeInterval : repeatTimeInterval target:self selector:@selector(updateAnimation:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
        }
    });
}

- (void)invalidate {
    __AEThreadSafeCall(^{
        if ([_animationTimer isValid]) {
            [_animationTimer invalidate];
            _animationTimer = nil;
        }
    });
}

- (void)addAEView:(UIView *)view identify:(NSString *)identify {
    __AEThreadSafeCall(^{
        if (self.animationDic[identify] == nil) {
            self.animationDic[identify] = view;
        }
    });
}

- (void)removeAllAEView {
    __AEThreadSafeCall(^{
        [self.animationDic removeAllObjects];
    });
}

- (void)removeAEViewWithIdentify:(NSString *)viewIdentify {
    __AEThreadSafeCall(^{
        [self.animationDic removeObjectForKey:viewIdentify];
    });
}

#pragma mark - private

- (void)updateAnimation:(NSTimer *)timer {
    __AEThreadSafeCall(^{
        NSTimeInterval currentTimeInterval = 0;
        switch (self.animationEffectMode) {
            case AEMode_TimeOffset:
                currentTimeInterval = self.delegate.currentTimeOffset;
                break;
            case AEMode_Ordinary:
                currentTimeInterval = timer.timeInterval;
                break;
            default:
                break;
        }
        for (UIView *AEView in self.animationDic.allValues) {
            for (<#type *object#> in <#collection#>) {
                <#statements#>
            }
        }
    });
}

#pragma mark - setter/getter

- (NSMutableDictionary *)animationDic {
    if (_animationDic == nil) {
        _animationDic = [NSMutableDictionary dictionary];
    }
    return _animationDic;
}

- (NSArray<NSString *> *)viewIdentifies {
    return self.animationDic.allKeys;
}

@end
