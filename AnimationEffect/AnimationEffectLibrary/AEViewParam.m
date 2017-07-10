//
//  AEViewParam.m
//  AnimationEffect
//
//  Created by fanglei on 2017/7/10.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "AEViewParam.h"

@implementation AEViewParam

- (id)copyWithZone:(NSZone *)zone {
    AEViewParam *param = [AEViewParam allocWithZone:zone];
    if (param) {
        param.transform = self.transform;
        param.opacity = self.opacity;
        param.originalAttributeString = self.originalAttributeString;
    }
    return param;
}

- (NSMutableAttributedString *)actualDisplayAttributeString {
    if (_actualDisplayAttributeString == nil) {
        return self.makeupAttributeString;
    }
    return _actualDisplayAttributeString;
}

- (NSMutableAttributedString *)makeupAttributeString {
    if (_makeupAttributeString == nil) {
        _makeupAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:self.originalAttributeString];
    }
    return _makeupAttributeString;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        AEViewParam *param = (AEViewParam *)object;
        return (param.opacity == self.opacity &&
                CATransform3DEqualToTransform(param.transform, self.transform) &&
                [param.originalAttributeString isEqualToAttributedString:self.originalAttributeString] &&
                [param.makeupAttributeString isEqualToAttributedString:self.makeupAttributeString]);
    }
    return NO;
}

@end
