//
//  GEMAPIService.m
//  VIPERSample
//
//  Created by Tung Duong Thanh on 9/20/16.
//  Copyright © 2016 GEM. All rights reserved.
//

#import "GEMAPIService.h"

@implementation GEMAPIService

- (instancetype)init {
    self = [super init];
    if (self) {
        _sessionTasks = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc {
    [self clearQueue];
}

- (void)clearQueue {
    for (NSURLSessionTask *task in self.sessionTasks) {
        [task cancel];
    }
    
    [self.sessionTasks removeAllObjects];
}

- (void)addToQueueSessionTaskWithTaskBuilder:(NSURLSessionTask *(^)())taskBuilder {
    NSURLSessionTask *task = taskBuilder();
    if (task) {
        [self.sessionTasks addObject:task];
    }
}

@end
