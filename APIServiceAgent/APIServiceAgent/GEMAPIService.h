//
//  GEMAPIService.h
//  VIPERSample
//
//  Created by Tung Duong Thanh on 9/20/16.
//  Copyright © 2016 GEM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GEMAPIService : NSObject

@property (nonatomic, strong) NSMutableArray<NSURLSessionTask *> *sessionTasks;

- (void)clearQueue;
- (void)addToQueueSessionTaskWithTaskBuilder:(NSURLSessionTask *(^)())taskBuilder;

@end
