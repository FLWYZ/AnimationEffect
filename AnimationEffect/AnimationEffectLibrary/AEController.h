//
//  AEController.h
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AEConstants.h"

@protocol AEControllerProtocol <NSObject>

@optional
@property (assign, nonatomic, readonly) NSTimeInterval currentTimeOffset;
@property (assign, nonatomic, readonly) BOOL pauseAnimation;

@end

@interface AEController : NSObject

@property (strong, nonatomic, readonly) NSArray<__kindof NSString*> *viewIdentifies;

@property (weak, nonatomic) id<AEControllerProtocol> delegate;

/**
 动效运行模式，默认是通过不断修改 timeOffset 来实现控制动效。
 一旦设置了，在动画执行中不能修改
 */
@property (assign, nonatomic, readonly) AEMode animationEffectMode;

+ (instancetype)controller;

/**
 根据控制模式和出发时间，开启动效。如果 repeatTimeInterval <= 0,则使用默认值 0.1s
 */
- (void)fireWithAEMode:(AEMode)animationEffectMode repeatTimeInterval:(NSTimeInterval)repeatTimeInterval;

- (void)invalidate;

- (void)addAEView:(UIView *)view identify:(NSString *)identify;

- (void)removeAEViewWithIdentify:(NSString *)viewIdentify;

- (void)removeAllAEView;

@end
