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

@property (strong, nonatomic, readonly) NSMutableArray<__kindof AERunInfo*> *runInfoArray;
@property (strong, nonatomic, readonly) AEViewParam *viewParam;

- (void)bindViewParam:(AEViewParam *)viewParam;

@end
