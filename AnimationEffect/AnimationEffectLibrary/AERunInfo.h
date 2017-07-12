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
@class AEViewParam;

@interface AERunInfo : NSObject

@property (weak, nonatomic) UIView *animationView;
@property (strong, nonatomic, readonly) AEParam *param;
@property (assign, nonatomic, readonly) NSTimeInterval animationPassedTime;
@property (assign, nonatomic, readonly) NSTimeInterval animationBeginTime;
@property (assign, nonatomic, readonly) NSTimeInterval animationCompleteTime;
@property (assign, nonatomic, readonly) NSTimeInterval animationDuration;
@property (assign, nonatomic) BOOL animationPaused;

@property (copy, nonatomic) void (^animationRunBlock)(NSTimeInterval timeOffset, NSTimeInterval timeInterval, AEViewParam *viewParam);

- (instancetype)initWithParam:(AEParam *)param;

- (void)configuratePassedTime:(NSTimeInterval)timeOffset timeInterval:(NSTimeInterval)timeInterval;

@end

@interface AEWipeRunInfo : AERunInfo

@property (strong, nonatomic) CAShapeLayer *wipeLayer;

@end

@interface AETextRunInfo : AERunInfo

@property (assign, nonatomic, readonly) NSRange effectRange;

@property (copy, nonatomic) NSRange (^runtimeEffectRangBlock)(NSTimeInterval timeOffset, NSTimeInterval timeInterval);

@property (copy, nonatomic) NSMutableDictionary* (^runtimeAttributeBlock)(NSMutableDictionary *attribute);

@end
