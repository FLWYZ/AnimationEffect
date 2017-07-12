//
//  UIView+AnimationEffect.h
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AEParam;
@class AERunInfo;
@class AEViewParam;

@interface UIView (AnimationEffect)

@property (strong, nonatomic, readonly) NSMutableDictionary *runInfoDictionary;
@property (strong, nonatomic, readonly) AEViewParam *viewParam;

- (AERunInfo *)addAnimationEffect:(AEParam *)param immediately:(BOOL)immdiately;

- (void)applyAnimationEffect:(AEViewParam *)viewParam;

- (void)removeAnimationEffect:(AERunInfo *)runInfo;

- (void)removeMultiAnimationEffects:(NSArray *)runInfoArray;

- (void)removeAllAnimationEffect;

@end
