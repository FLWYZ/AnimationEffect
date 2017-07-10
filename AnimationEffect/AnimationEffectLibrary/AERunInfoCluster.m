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

@property (strong, nonatomic, readwrite) NSMutableArray<__kindof AERunInfo*> *runInfoArray;
@property (strong, nonatomic, readwrite) AEViewParam *viewParam;

@end

@implementation AERunInfoCluster

- (void)bindViewParam:(AEViewParam *)viewParam {
    self.viewParam = viewParam;
}

- (NSMutableArray<AERunInfo *> *)runInfoArray {
    if (_runInfoArray == nil) {
        _runInfoArray = [NSMutableArray array];
    }
    return _runInfoArray;
}

@end
