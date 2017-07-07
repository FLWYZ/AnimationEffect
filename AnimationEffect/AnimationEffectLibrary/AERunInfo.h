//
//  AERunInfo.h
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//  动效运行时参数

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AEConstants.h"

@class AEParam;

@interface AERunInfo : NSObject

@property (weak, nonatomic) CALayer *animationLayer;
@property (weak, nonatomic) UIView *animationView;
@property (strong, nonatomic) CAAnimation *animation;
@property (assign, nonatomic, readonly) NSTimeInterval animationStartTimeStamp;
@property (assign, nonatomic, readonly) NSTimeInterval animationEndTimeStamp;
@property (copy, nonatomic) void(^animationRunBlock)(NSTimeInterval timeInterval, AEMode mode);
@property (copy, nonatomic) NSString *animationKey;
@property (assign, nonatomic) NSTimeInterval animationPassedTime;

- (instancetype)initWithAnimation:(CAAnimation *)animation
                            layer:(CALayer *)animationLayer
                             view:(UIView *)view
                            param:(AEParam *)param;

- (void)adjustAnimationPassedTimeOffset:(NSTimeInterval)timeInterval mode:(AEMode)mode;

@end

@interface AEPartialTextEffectRunInfo : AERunInfo

@property (weak, nonatomic) UILabel *label;
@property (assign, nonatomic, readonly) NSRange effectRange;
@property (copy, nonatomic) NSRange (^runtimeEffectRangeBlock)(NSTimeInterval timeOffset,AEMode mode);
@property (copy, nonatomic) NSMutableDictionary *(^runtimeTextAttributeBlock)(NSTimeInterval timeOffset, NSMutableDictionary *attribute, AEMode mode);

- (instancetype)initWithParam:(AEParam *)param;

- (BOOL)effectValidAtIndex:(NSUInteger)index
                timeOffset:(NSTimeInterval)currentTimeOffset
                      mode:(AEMode)mode;

- (BOOL)

@end

@interface AERunInfoCluster : NSObject

@property (strong, nonatomic, readonly) NSMutableArray<__kindof AERunInfo*> *runInfoArray;
@property (strong, nonatomic, readonly) NSMutableArray<__kindof AEPartialTextEffectRunInfo*> *typingRunInfoArray;
@property (strong, nonatomic, readonly) NSMutableArray<__kindof AEPartialTextEffectRunInfo*> *partialTextEffectRunInfoArray;

@end
