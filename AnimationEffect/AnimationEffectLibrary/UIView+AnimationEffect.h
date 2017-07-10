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

@property (strong, nonatomic, readonly) NSMutableArray<__kindof AERunInfo*> *runInfoArray;
@property (strong, nonatomic, readonly) AEViewParam *viewParam;

- (AERunInfo *)addAnimationEffect:(AEParam *)param immediately:(BOOL)immdiately;

- (void)removeAnimationEffect:(NSString *)animationKey;

@end
