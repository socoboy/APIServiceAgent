//
//  DemoServiceAPIAgent.m
//  APIServiceAgent
//
//  Created by Tung Duong Thanh on 8/10/16.
//  Copyright © 2016 GEM. All rights reserved.
//

#import "DemoServiceAPIAgent.h"

@implementation DemoServiceAPIAgent

- (NSMutableURLRequest *)addAuthorizedTokenToRequest:(NSMutableURLRequest *)request {
    // temporary do nothing
    return request;
}

+ (NSError *)handleServiceError:(NSError *)serviceError response:(NSURLResponse *)response responseObject:(id)responseObject {
    // temporary no need to handler error
    return serviceError;
}

+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
                    uploadProgress:(void (^)(NSProgress *))uploadProgress
                  downloadProgress:(void (^)(NSProgress *))downloadProgress
             expectedResponseClass:(Class)expectedClass
                      elementClass:(Class)elementClass
                        completion:(void (^)(id, NSError *))completion
           dispatchCompletionQueue:(NSOperationQueue *)completionQueue {
    /*
     *  Only override this case because of This Response API doesn't contains "result" key, not conform to common response format
     *  The common response format should be an dictionary with keys:
     *      - result: contain response data object
     *      - messageKey: message key to mapping on client side to get appropriated message
     *      - overrideMessage: message to override client mapping message
     */
    return [self startRequest:request uploadProgress:uploadProgress downloadProgress:downloadProgress responseMappingBlock:^id(id rawResponse, NSError *__autoreleasing *error) {
        id convertedObject = nil;
        if (![rawResponse isKindOfClass:[NSDictionary class]]) {
            *error = [NSError errorWithDomain:@"Service Parser Error" code:1002 userInfo:@{NSLocalizedDescriptionKey: @"Service API Response Type not JSONSerializable"}];
        } else {
            convertedObject = [self convertResponseObject:rawResponse toDTOObjectClass:expectedClass elementClass:elementClass withError:error];
        }
        return convertedObject;
    } completion:completion dispatchCompletionQueue:completionQueue];
}

@end
