//
//  UIView+AEBuilder.h
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEConstants.h"

@class AERunInfo;
@class AEParam;

@interface UIView (AEBuilder)

- (AERunInfo *)buildAnimationEffectWithParam:(AEParam *)param;

@end
