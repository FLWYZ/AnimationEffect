//
//  AEParam.m
//  AnimationEffect
//
//  Created by fanglei on 2017/6/28.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "AEParam.h"

@implementation AEParam

- (instancetype)init {
    if (self = [super init]) {
        self.minimumScaling = AEMinimumScalingDefault;
        self.maximumScaling = AEMaximumScalingDefault;
        self.rotationDegree = AERotationDegreeDefault;
        self.wipeDirection = AEWipeDirectionDefault;
        self.minimumOpacity = AEMinimumOpacityDefault;
        self.typingMode = AETyping_Letter;
        self.removAnimationOnCompletion = NO;
        self.fillMode = kCAFillModeForwards;
    }
    return self;
}

- (NSRange)partialTextEffectRange {
    return NSMakeRange(self.partialTextStartLetterIndex, self.partialTextEndLetterIndex - self.partialTextStartLetterIndex + 1);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%lu-%.2f-%.2f-%.2f-%.2f-%.3f-%lu-%.2f-%lu-%lu-%lu-%@-%@-%i-%@-%@",(unsigned long)self.animationType,self.startTimeStamp,self.duration,self.minimumScaling,self.maximumScaling,self.rotationDegree,(unsigned long)self.wipeDirection,self.minimumOpacity,(unsigned long)self.partialTextStartLetterIndex,(unsigned long)self.partialTextEndLetterIndex,(unsigned long)self.typingMode,self.textNewColor,self.textNewBgColor,self.removAnimationOnCompletion,self.fillMode,NSStringFromRange(self.partialTextEffectRange)];
}

@end
