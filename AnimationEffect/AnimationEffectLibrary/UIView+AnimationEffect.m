//
//  UIView+AnimationEffect.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "UIView+AnimationEffect.h"
#import <objc/runtime.h>
#import "AEParam.h"
#import "AERunInfo.h"
#import "UIView+AEBuilder.h"
#import "UILabel+AEExtension.h"
#import "AERunInfoCluster.h"
#import "AEController.h"
#import "AEConstants.h"

static void *kAERunInfoClusterKey = &kAERunInfoClusterKey;

@interface UIView()

@property (strong, nonatomic) AERunInfoCluster *runInfoCluster;

@end

@implementation UIView (AnimationEffect)

- (AERunInfo *)addAnimationEffect:(AEParam *)param
                      immediately:(BOOL)immdiately {
    
}

- (void)removeAnimationEffect {
    self.runInfoCluster = nil;
    self.layer.mask = nil;
}

#pragma mark - setter/getter

- (void)sortAniamtionEffect {
    
}

/**
 需要支持局部文本动效的类型集合
 */
- (NSArray *)textSeriesEffect {
    return @[@(AEType_FadeIn),
             @(AEType_FadeOut),
             @(AEType_Spark),
             @(AEType_Typing),
             @(AEType_ChangeTextColor),
             @(AEType_ChangeTextBgColor),
             @(AEType_Underlining)];
}

#pragma mark - setter/getter

- (void)setRunInfoCluster:(AERunInfoCluster *)runInfoCluster {
    objc_setAssociatedObject(self, kAERunInfoClusterKey, runInfoCluster, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AERunInfoCluster *)runInfoCluster {
    AERunInfoCluster *runInfoCluster = objc_getAssociatedObject(self, kAERunInfoClusterKey);
    if (runInfoCluster == nil) {
        runInfoCluster = [[AERunInfoCluster alloc] init];
        self.runInfoCluster = runInfoCluster;
    }
    return runInfoCluster;
}

- (NSMutableArray<AERunInfo *> *)runInfoArray {
    return self.runInfoCluster.runInfoArray;
}

- (AEViewParam *)viewParam {
    return self.runInfoCluster.viewParam;
}

@end
