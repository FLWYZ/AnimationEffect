//
//  AEController.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "AEController.h"
#import "AEConstants.h"
#import "UIView+AnimationEffect.h"
#import "AERunInfo.h"
#import "AEViewParam.h"

static inline void __AEThreadSafeCall(void(^action)(void)) {
    dispatch_async(dispatch_get_main_queue(), action);
}

@interface AEController()

@property (strong, nonatomic) NSTimer *animationTimer;
@property (strong, nonatomic) NSMutableArray *animationViews;
@property (assign, nonatomic) NSTimeInterval timeOffset;

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

- (void)fire {
    __AEThreadSafeCall(^{
        if (_animationTimer == nil) {
            _animationTimer = [NSTimer scheduledTimerWithTimeInterval:kAETimeInterval target:self selector:@selector(updateAnimation:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
        }
    });
}

- (void)invalidate:(BOOL)resetTimeOffset removeAllAEView:(BOOL)removeAll {
    __AEThreadSafeCall(^{
        if ([_animationTimer isValid]) {
            [_animationTimer invalidate];
            _animationTimer = nil;
        }
        if (resetTimeOffset == YES) {
            self.timeOffset = 0;
        }
        if (removeAll) {
            [self.animationViews removeAllObjects];
        }
    });
}

- (void)addAEView:(UIView *)view{
    __AEThreadSafeCall(^{
        if (view != nil) {
            [self.animationViews addObject:view];
        }
    });
}

- (void)removeAEView:(UIView *)view {
    __AEThreadSafeCall(^{
        if (view != nil && [self.animationViews containsObject:view]) {
            [self.animationViews removeObject:view];
        }
    });
}

- (void)removeAllAEView {
    __AEThreadSafeCall(^{
        [self.animationViews removeAllObjects];
    });
}

#pragma mark - private

- (void)updateAnimation:(NSTimer *)timer {
    __AEThreadSafeCall(^{
        @autoreleasepool {
            self.timeOffset += timer.timeInterval;
            NSTimeInterval timeOffset = [self.delegate respondsToSelector:@selector(currentTimeOffset)] ? self.delegate.currentTimeOffset : self.timeOffset;
            for (UIView *view in self.animationViews) {
                NSMutableArray *removeAnimationAarray = [NSMutableArray array];
                AEViewParam *param = [view.viewParam copy];
                for (AERunInfo *runInfo in view.runInfoDictionary.allValues) {
                    if ([self removeAnimationBeforeRun:runInfo onView:view timeOffset:timeOffset]) {
                        [removeAnimationAarray addObject:runInfo];
                        continue;
                    }
                    runInfo.animationPaused = [self pauseAnimationBeforeRun:runInfo onView:view timeOffset:timeOffset];
                    runInfo.animationRunBlock(timeOffset, timer.timeInterval, param);
                    if ([self removeAnimationAfterRun:runInfo onView:view timeOffset:timeOffset]) {
                        [removeAnimationAarray addObject:runInfo];
                        continue;
                    }
                    runInfo.animationPaused = [self pauseAnimationAfterRun:runInfo onView:view timeOffset:timeOffset];
                }
                [view applyAnimationEffect:param];
                [view removeMultiAnimationEffects:removeAnimationAarray];
            }
        }
    });
}

- (BOOL)pauseAnimationBeforeRun:(AERunInfo *)runInfo
                         onView:(UIView *)view
                     timeOffset:(NSTimeInterval)timeOffset {
    if ([self.delegate respondsToSelector:@selector(pauseAnimationBeforeRun:onView:timeOffset:)]) {
        return [self.delegate pauseAnimationBeforeRun:runInfo onView:view timeOffset:timeOffset];
    } else {
        return runInfo.animationPaused;
    }
}

- (BOOL)removeAnimationBeforeRun:(AERunInfo *)runInfo
                          onView:(UIView *)view
                      timeOffset:(NSTimeInterval)timeOffset {
    if ([self.delegate respondsToSelector:@selector(removeAnimationBeforeRun:onView:timeOffset:)]) {
        return [self.delegate removeAnimationBeforeRun:runInfo onView:view timeOffset:timeOffset];
    }
    return NO;
}

- (BOOL)pauseAnimationAfterRun:(AERunInfo *)runInfo
                        onView:(UIView *)view
                    timeOffset:(NSTimeInterval)timeOffset {
    if ([self.delegate respondsToSelector:@selector(pauseAnimationAfterRun:onView:timeOffset:)]) {
        return [self.delegate pauseAnimationAfterRun:runInfo onView:view timeOffset:timeOffset];
    }
    return NO;
}

- (BOOL)removeAnimationAfterRun:(AERunInfo *)runInfo
                         onView:(UIView *)view
                     timeOffset:(NSTimeInterval)timeOffset {
    if ([self.delegate respondsToSelector:@selector(removeAnimationAfterRun:onView:timeOffset:)]) {
        return [self.delegate removeAnimationAfterRun:runInfo onView:view timeOffset:timeOffset];
    }
    return NO;
}

#pragma mark - setter/getter

- (NSMutableArray *)animationViews {
    if (_animationViews == nil) {
        _animationViews = [NSMutableArray array];
    }
    return _animationViews;
}

- (void)setDelegate:(id<AEControllerProtocol>)delegate {
    if (delegate != nil && _delegate != delegate) {
        [self invalidate:YES removeAllAEView:YES];
    }
    _delegate = delegate;
}

@end
