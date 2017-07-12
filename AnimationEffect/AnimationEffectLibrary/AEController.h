//
//  AEController.h
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AERunInfo;

@protocol AEControllerProtocol <NSObject>

@optional

/**
 如果实现了这个代理方法，当前时间偏量就从代理方法获得；
 如果不实现的话，当前时间偏量由 AEController 自行管理
 */
@property (assign, nonatomic, readonly) NSTimeInterval currentTimeOffset;

- (BOOL)pauseAnimationBeforeRun:(AERunInfo *)runInfo onView:(UIView *)view timeOffset:(NSTimeInterval)timeOffset;

- (BOOL)removeAnimationBeforeRun:(AERunInfo *)runInfo onView:(UIView *)view timeOffset:(NSTimeInterval)timeOffset;

- (BOOL)pauseAnimationAfterRun:(AERunInfo *)runInfo onView:(UIView *)view timeOffset:(NSTimeInterval)timeOffset;

- (BOOL)removeAnimationAfterRun:(AERunInfo *)runInfo onView:(UIView *)view timeOffset:(NSTimeInterval)timeOffset;

@end

@interface AEController : NSObject

@property (weak, nonatomic) id<AEControllerProtocol> delegate;

+ (instancetype)controller;

/**
 开始控制动效
 */
- (void)fire;

/**
 停止动效计时器
 */
- (void)invalidate:(BOOL)resetTimeOffset removeAllAEView:(BOOL)removeAll;

- (void)addAEView:(UIView *)view;

- (void)removeAEView:(UIView *)view;

- (void)removeAllAEView;

@end
