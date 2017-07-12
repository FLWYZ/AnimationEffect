//
//  AERunInfoCluster.m
//  AnimationEffect
//
//  Created by fanglei on 2017/7/10.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import "AERunInfoCluster.h"
#import "AEParam.h"
#import "AEViewParam.h"

@interface AERunInfoCluster()

@property (strong, nonatomic, readwrite) NSMutableDictionary *runInfoDictionary;
@property (strong, nonatomic, readwrite) AEViewParam *viewParam;

@end

@implementation AERunInfoCluster

- (void)bindViewParam:(AEViewParam *)viewParam {
    self.viewParam = viewParam;
}

- (NSMutableDictionary *)runInfoDictionary {
    if (_runInfoDictionary == nil) {
        _runInfoDictionary = [NSMutableDictionary dictionary];
    }
    return _runInfoDictionary;
}

- (BOOL)hasBindViewParam {
    return self.viewParam != nil;
}

@end
