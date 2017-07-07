//
//  AERunInfo.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "AERunInfo.h"
#import "AEParam.h"

@interface AERunInfo()

@property (assign, nonatomic, readwrite) NSTimeInterval animationStartTimeStamp;
@property (assign, nonatomic, readwrite) NSTimeInterval animationEndTimeStamp;

@end

@implementation AERunInfo

- (instancetype)initWithAnimation:(CAAnimation *)animation layer:(CALayer *)animationLayer view:(UIView *)view param:(AEParam *)param {
    if (self = [super init]) {
        self.animationView = view;
        self.animation = animation;
        self.animationLayer = animationLayer;
        self.animationStartTimeStamp = param.startTimeStamp;
        self.animationEndTimeStamp = param.startTimeStamp + param.duration;
    }
    return self;
}

- (void)adjustAnimationPassedTimeOffset:(NSTimeInterval)timeInterval mode:(AEMode)mode {
    switch (mode) {
        case AEMode_Ordinary:
            self.animationPassedTime += timeInterval;
            break;
        case AEMode_TimeOffset:
            self.animationPassedTime = timeInterval;
            break;
        default:
            break;
    }
}

- (void (^)(NSTimeInterval, AEMode))animationRunBlock {
    if (_animationRunBlock == nil) {
        __weak typeof(self) weakSelf = self;
        _animationRunBlock = ^(NSTimeInterval timeInterval,AEMode mode){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.animationLayer != nil) {
                [strongSelf adjustAnimationPassedTimeOffset:timeInterval mode:mode];
                if (strongSelf.animationLayer.timeOffset != strongSelf.animationPassedTime) {
                    strongSelf.animationLayer.timeOffset = strongSelf.animationPassedTime;
                }
            }
        };
    }
    return _animationRunBlock;
}

@end

@interface AEPartialTextEffectRunInfo()

@property (assign, nonatomic, readwrite) NSRange effectRange;
@property (assign, nonatomic) CGFloat effectLetterLengthPerSec;

@end

@implementation AEPartialTextEffectRunInfo

- (instancetype)initWithParam:(AEParam *)param {
    if (self = [super initWithAnimation:nil layer:nil view:nil param:param]) {
        self.effectRange = param.partialTextEffectRange;
        self.effectLetterLengthPerSec = self.effectRange.length * 1.0 / param.duration;
    }
    return self;
}

- (BOOL)effectValidAtIndex:(NSUInteger)index
                timeOffset:(NSTimeInterval)currentTimeOffset
                      mode:(AEMode)mode {
    NSRange currentEffectRange = self.runtimeEffectRangeBlock(currentTimeOffset,mode);
    return NSLocationInRange(index, currentEffectRange);
}

- (NSRange (^)(NSTimeInterval, AEMode))runtimeEffectRangeBlock {
    if (_runtimeEffectRangeBlock == nil) {
        __weak typeof(self) weakSelf = self;
        _runtimeEffectRangeBlock = ^NSRange(NSTimeInterval timeOffset, AEMode mode) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf adjustAnimationPassedTimeOffset:timeOffset mode:mode];
            if (strongSelf.animationPassedTime < strongSelf.animationStartTimeStamp) {
                return NSMakeRange(0, 0);
            } else if (strongSelf.animationStartTimeStamp > strongSelf.animationEndTimeStamp) {
                return strongSelf.effectRange;
            } else {
                NSUInteger effectLength = (strongSelf.animationPassedTime - strongSelf.animationStartTimeStamp) * strongSelf.effectLetterLengthPerSec;
                return NSMakeRange(strongSelf.effectRange.location, effectLength);
            }
        };
    }
    return _runtimeEffectRangeBlock;
}

@end

@interface AERunInfoCluster()

@property (strong, nonatomic, readwrite) NSMutableArray<__kindof AERunInfo*> *runInfoArray;
@property (strong, nonatomic, readwrite) NSMutableArray<__kindof AEPartialTextEffectRunInfo*> *typingRunInfoArray;
@property (strong, nonatomic, readwrite) NSMutableArray<__kindof AEPartialTextEffectRunInfo*> *partialTextEffectRunInfoArray;

@end

@implementation AERunInfoCluster

- (NSMutableArray<AERunInfo *> *)runInfoArray {
    if (_runInfoArray == nil) {
        _runInfoArray = [NSMutableArray array];
    }
    return _runInfoArray;
}

- (NSMutableArray<AEPartialTextEffectRunInfo *> *)typingRunInfoArray {
    if (_typingRunInfoArray == nil) {
        _typingRunInfoArray = [NSMutableArray array];
    }
    return _typingRunInfoArray;
}

- (NSMutableArray<AEPartialTextEffectRunInfo *> *)partialTextEffectRunInfoArray {
    if (_partialTextEffectRunInfoArray == nil) {
        _partialTextEffectRunInfoArray = [NSMutableArray array];
    }
    return _partialTextEffectRunInfoArray;
}

@end
