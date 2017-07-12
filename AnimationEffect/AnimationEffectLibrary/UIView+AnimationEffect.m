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
#import "AEViewParam.h"

static void *kAERunInfoClusterKey = &kAERunInfoClusterKey;

@interface UIView()

@property (strong, nonatomic) AERunInfoCluster *runInfoCluster;

@end

@implementation UIView (AnimationEffect)

- (AERunInfo *)addAnimationEffect:(AEParam *)param {
    if ([self isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self;
        [label bindOringinalAtrributeString];
        if ([param isKindOfClass:[AETextSeriesParam class]]) {
            AETextSeriesParam *textSeriesParam = (AETextSeriesParam *)param;
            if (textSeriesParam.effectRange.length <= 0 ||
                textSeriesParam.effectRange.length > label.originalAttributeString.length) {
                textSeriesParam.effectRange = NSMakeRange(0, label.originalAttributeString.length);
            }
        }
    }
    if (self.runInfoCluster.hasBindViewParam == NO) {
        [self.runInfoCluster bindViewParam:[[AEViewParam alloc] initWithView:self]];
    }
    AERunInfo *runInfo = [self buildAnimationEffectWithParam:param];
    if (runInfo != nil) {
        [self.runInfoDictionary setObject:runInfo forKey:runInfo.description];
        [[AEController controller] addAEView:self];
        return runInfo;
    }
    return nil;
}

- (void)applyAnimationEffect:(AEViewParam *)viewParam {
    if (CATransform3DEqualToTransform(self.layer.transform, viewParam.transform) == NO) {
        self.layer.transform = viewParam.transform;
    }
    if (self.layer.opacity != viewParam.opacity) {
        self.layer.opacity = viewParam.opacity;
    }
    if ([self isKindOfClass:[UILabel class]]) {
        if ([((UILabel *)self).attributedText isEqualToAttributedString:viewParam.actualDisplayAttributeString] == NO) {
            ((UILabel *)self).attributedText = viewParam.actualDisplayAttributeString;
        }
    }
}

- (void)removeAnimationEffect:(AERunInfo *)runInfo {
    [self.runInfoDictionary removeObjectForKey:runInfo.description];
}

- (void)removeMultiAnimationEffects:(NSArray *)runInfoArray {
    for (AERunInfo *runInfo in runInfoArray) {
        [self removeAnimationEffect:runInfo];
    }
}

- (void)removeAllAnimationEffect {
    self.runInfoCluster = nil;
    self.layer.mask = nil;
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

- (NSMutableDictionary *)runInfoDictionary {
    return self.runInfoCluster.runInfoDictionary;
}

- (AEViewParam *)viewParam {
    return self.runInfoCluster.viewParam;
}

@end
