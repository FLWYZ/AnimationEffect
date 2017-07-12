//
//  AERunInfoCluster.h
//  AnimationEffect
//
//  Created by fanglei on 2017/7/10.
//  Copyright © 2017年 FangLei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AERunInfo;
@class AETextRunInfo;
@class AEViewParam;

@interface AERunInfoCluster : NSObject

@property (strong, nonatomic, readonly) NSMutableDictionary *runInfoDictionary;
@property (strong, nonatomic, readonly) AEViewParam *viewParam;
@property (assign, nonatomic, readonly, getter = hasBindViewParam) BOOL bindViewParam;

- (void)bindViewParam:(AEViewParam *)viewParam;

@end
