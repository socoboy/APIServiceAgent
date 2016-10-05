//
//  HLServiceAPIRequestBuilder.m
//  hocvalam
//
//  Created by Tung Duong Thanh on 7/27/16.
//  Copyright © 2016 GEM. All rights reserved.
//

#import "GEMServiceAPIAgent.h"
#import <JSONModel.h>

static NSString * const GEMServiceAPIAgentResponseResultKey = @"result";
static NSString * const GEMServiceAPIAgentResponseErrorCodeKey = @"errorCode";
static NSString * const GEMServiceAPIAgentResponseMessageKey = @"message";

@interface GEMServiceAPIAgent ()

@property (nonatomic, strong) NSString *apiServiceVersion;

- (NSMutableURLRequest *)unauthorizedRequestWithMethod:(NSString *)method
                                                params:(NSDictionary *)params
                                                  path:(NSString *)path
                                                 error:(NSError *__autoreleasing *)error;
- (NSMutableURLRequest *)authorizedRequestWithMethod:(NSString *)method
                                              params:(NSDictionary *)params
                                                path:(NSString *)path
                                               error:(NSError *__autoreleasing *)error;
@end

@implementation GEMServiceAPIAgent

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    static GEMServiceAPIAgent *instance = nil;
    dispatch_once( &predicate, ^{
        NSString *baseURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"APP_SERVICE_ENDPOINT_URL"];
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    } );
    return instance;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration
{
    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (self) {
        // do something after init
        _apiServiceVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"APP_SERVICE_ENDPOINT_VERSION"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        self.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

- (NSMutableURLRequest *)unauthorizedRequestWithMethod:(NSString *)method params:(NSDictionary *)params path:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSString *requestURLString = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:requestURLString parameters:params error:error];
    if (error && *error) {
        return nil;
    } else {
        return request;
    }
}

- (NSMutableURLRequest *)authorizedRequestWithMethod:(NSString *)method params:(NSDictionary *)params path:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *request = [self unauthorizedRequestWithMethod:method params:params.copy path:path error:error];
    if (error && *error) {
        return nil;
    } else {
        return [self addAuthorizedTokenToRequest:request];
    }
}

- (NSMutableURLRequest *)addAuthorizedTokenToRequest:(NSMutableURLRequest *)request {
    @throw [NSException exceptionWithName:@"Should be implmented in subclasses" reason:@"Should be implemented in subclasses" userInfo:nil];
}

+ (NSError *)handleServiceError:(NSError *)serviceError response:(NSURLResponse *)response responseObject:(id)responseObject {
    @throw [NSException exceptionWithName:@"Should be implmented in subclasses" reason:@"Should be implemented in subclasses" userInfo:nil];
}

//------------------------------------------------------------------------------------------------s
+ (NSMutableURLRequest *)getAuthorizedRequestWithPath:(NSString *)path params:(NSDictionary *)params error:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] authorizedRequestWithMethod:@"GET" params:params path:path error:error];
}

+ (NSMutableURLRequest *)postAuthorizedRequestWithPath:(NSString *)path params:(NSDictionary *)params payload:(NSData *)payload error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *request = [[self sharedInstance] authorizedRequestWithMethod:@"POST" params:params path:path error:error];
    if (error && *error) {
        return nil;
    } else {
        [request setHTTPBody:payload];
        return request;
    }
}

+ (NSMutableURLRequest *)postAutorizedMultipartRequestWithParam:(NSDictionary *)params path:(NSString *)path constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block error:(NSError *__autoreleasing *)error {
    GEMServiceAPIAgent *sharedInstance = [GEMServiceAPIAgent sharedInstance];
    NSString *requestURLString = [[NSURL URLWithString:path relativeToURL:[sharedInstance baseURL]] absoluteString];
    NSMutableURLRequest *request = [sharedInstance.requestSerializer multipartFormRequestWithMethod:@"" URLString:requestURLString parameters:params constructingBodyWithBlock:block error:error];
    
    return request;
}

+ (NSMutableURLRequest *)getUnauthorizedRequestWithPath:(NSString *)path params:(NSDictionary *)params error:(NSError *__autoreleasing *)error {
    return [[self sharedInstance] unauthorizedRequestWithMethod:@"GET" params:params path:path error:error];
}

+ (NSMutableURLRequest *)postUnauthorizedRequestWithPath:(NSString *)path params:(NSDictionary *)params payload:(NSData *)payload error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *request = [[self sharedInstance] unauthorizedRequestWithMethod:@"POST" params:params path:path error:error];
    if (error && *error) {
        return nil;
    } else {
        [request setHTTPBody:payload];
        return request;
    }
}

//-------------------------------------------------------------------------------------------------
#pragma mark + Start request
+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
             expectedResponseClass:(Class)expectedClass
                        completion:(void (^)(id, NSError *))completion {
    return [self startRequest:request
        expectedResponseClass:expectedClass
                   completion:completion
      dispatchCompletionQueue:nil];
}

+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
             expectedResponseClass:(Class)expectedClass
                        completion:(void (^)(id, NSError *))completion
           dispatchCompletionQueue:(NSOperationQueue *)completionQueue {
    return [self startRequest:request
               uploadProgress:nil
             downloadProgress:nil
        expectedResponseClass:expectedClass
                 elementClass:nil
                   completion:completion
      dispatchCompletionQueue:completionQueue];
}

+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
     expectedArrayWithElementClass:(Class)elementClass
                        completion:(void (^)(id, NSError *))completion {
    return [self startRequest:request
expectedArrayWithElementClass:elementClass
                   completion:completion
      dispatchCompletionQueue:nil];
}

+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
     expectedArrayWithElementClass:(Class)elementClass
                        completion:(void (^)(id, NSError *))completion
           dispatchCompletionQueue:(NSOperationQueue *)completionQueue {
    return [self startRequest:request
               uploadProgress:nil
             downloadProgress:nil
        expectedResponseClass:[NSArray class]
                 elementClass:elementClass
                   completion:completion
      dispatchCompletionQueue:completionQueue];
}

+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
                    uploadProgress:(void (^)(NSProgress *))uploadProgress
                  downloadProgress:(void (^)(NSProgress *))downloadProgress
              responseMappingBlock:(id (^)(id, NSError *__autoreleasing *))responseMappingBlock
                        completion:(void (^)(id, NSError *))completion {
    return [self startRequest:request
               uploadProgress:uploadProgress
             downloadProgress:downloadProgress
         responseMappingBlock:responseMappingBlock
                   completion:completion
      dispatchCompletionQueue:nil];
}

+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
                    uploadProgress:(void (^)(NSProgress *))uploadProgress
                  downloadProgress:(void (^)(NSProgress *))downloadProgress
              responseMappingBlock:(id (^)(id, NSError *__autoreleasing *))responseMappingBlock
                        completion:(void (^)(id, NSError *))completion
           dispatchCompletionQueue:(NSOperationQueue *)completionQueue {
    
    NSURLSessionTask *task = [[self sharedInstance] dataTaskWithRequest:request uploadProgress:uploadProgress downloadProgress:downloadProgress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        DDLogInfo(@"====Request complete: %@", request.debugDescription);
        DDLogDebug(@"====Response: \n %@", response.debugDescription);
        if (error) {
            DDLogInfo(@"REQUEST ERROR - Handle Request error");
            DDLogError(@"RESPONSE ERROR: %@", error.debugDescription);
            DDLogError(@"RESPONSE ERROR BODY: %@", [responseObject debugDescription]);
            
            if (error.code == NSURLErrorCancelled && [error.domain isEqualToString:NSURLErrorDomain]) {
                // request canceled, don't execute callback block
                return;
            }
            
            if (!response || !responseObject) {
                // service doesn't return any response, call callback with error catched
                // this error created by AFNetworking
                if (completion) {
                    if (completionQueue) {
                        [completionQueue addOperationWithBlock:^{
                            completion(nil, error);
                        }];
                    } else {
                        completion(nil, error);
                    }
                }
                return;
            }
            
            // service has both response and error, need to handle response + error
            // This should be handled based on project domain. Cannot handle generically
            // Call completion with error processed
            NSError *handledError = [self handleServiceError:error response:response responseObject:responseObject];
            // if handledError nil => don't need to call completion
            if (completion && handledError) {
                if (completionQueue) {
                    [completionQueue addOperationWithBlock:^{
                        completion(nil, handledError);
                    }];
                } else {
                    completion(nil, handledError);
                }
            }
            
            return;
        } else {
            DDLogInfo(@"REQUEST SUCCESS - Handle response");
            DDLogDebug(@"RESPONSE OBJECT: \n %@", [responseObject debugDescription]);
            // success
            NSError *parserError = nil;
            id convertedObject = responseMappingBlock(responseObject, &parserError);
            if (completion) {
                if (completionQueue) {
                    [completionQueue addOperationWithBlock:^{
                        completion(convertedObject, parserError);
                    }];
                } else {
                    completion(convertedObject, parserError);
                }
            }
        }
    }];
    
    [task resume];
    return task;
}

+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
                    uploadProgress:(void (^)(NSProgress *))uploadProgress
                  downloadProgress:(void (^)(NSProgress *))downloadProgress
             expectedResponseClass:(__unsafe_unretained Class)expectedClass
                      elementClass:(__unsafe_unretained Class)elementClass
                        completion:(void (^)(id, NSError *))completion {
    return [self startRequest:request
               uploadProgress:uploadProgress
             downloadProgress:downloadProgress
        expectedResponseClass:expectedClass
                 elementClass:elementClass
                   completion:completion
      dispatchCompletionQueue:nil];
}

+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
                    uploadProgress:(void (^)(NSProgress *))uploadProgress
                  downloadProgress:(void (^)(NSProgress *))downloadProgress
             expectedResponseClass:(Class)expectedClass
                      elementClass:(Class)elementClass
                        completion:(void (^)(id, NSError *))completion
           dispatchCompletionQueue:(NSOperationQueue *)completionQueue {
    return [self startRequest:request uploadProgress:uploadProgress downloadProgress:downloadProgress responseMappingBlock:^id(id rawResponse, NSError *__autoreleasing *error) {
        id convertedObject = nil;
        if (![rawResponse isKindOfClass:[NSDictionary class]]) {
            *error = [NSError errorWithDomain:@"Service Parser Error" code:1002 userInfo:@{NSLocalizedDescriptionKey: @"Service API Response Type not JSONSerializable"}];
        } else if (expectedClass && ![rawResponse objectForKey:GEMServiceAPIAgentResponseResultKey]) {
            *error = [NSError errorWithDomain:@"Service Parser Error" code:1003 userInfo:@{NSLocalizedDescriptionKey: @"Service API Response doesn't has result key"}];
        } else {
            convertedObject = [self convertResponseObject:[rawResponse objectForKey:GEMServiceAPIAgentResponseResultKey] toDTOObjectClass:expectedClass elementClass:elementClass withError:error];
        }
        return convertedObject;
    } completion:completion dispatchCompletionQueue:completionQueue];
}

//-------------------------------------------------------------------------------------------------
/**
 *  @param elementClass   Class for element in an array (could be NSString, NSDictionary, JSONModel), Class of Element not allowed to be NSArray
 */
+ (id)convertResponseObject:(id)responseObject toDTOObjectClass:(Class)class elementClass:(Class)elementClass withError:(NSError *__autoreleasing *)error {
    if (!class) {
        return responseObject;
    }
    
    if ([NSStringFromClass(class) isEqualToString:@"NSString"]) {
        if ([responseObject isKindOfClass:[NSString class]]) {
            return responseObject;
        } else {
            *error = [NSError errorWithDomain:@"Service Parser Error" code:1004 userInfo:@{NSLocalizedDescriptionKey: @"Service API Response expected String but result object is not string"}];
            return nil;
        }
    } else if ([NSStringFromClass(class) isEqualToString:@"NSDictionary"]) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            return responseObject;
        } else {
            *error = [NSError errorWithDomain:@"Service Parser Error" code:1004 userInfo:@{NSLocalizedDescriptionKey: @"Service API Response expected Dictionary but result object is not Dictionary"}];
            return nil;
        }
    } else if ([NSStringFromClass(class) isEqualToString:@"NSArray"]) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            if (elementClass) {
                if ([NSStringFromClass(elementClass) isEqualToString:@"NSArray"]) {
                    // Exception. It not allowed to be NSArray
                    *error = [NSError errorWithDomain:@"Service Parser Error" code:1005 userInfo:@{NSLocalizedDescriptionKey: @"Service API Response expected NSArray with element, but element expect NSArray too. Element Class not allowed to be NSArray"}];
                    return nil;
                } else {
                    NSMutableArray *responseArray = [NSMutableArray new];
                    for (id responseElement in responseObject) {
                        id parsedElement = [self convertResponseObject:responseElement toDTOObjectClass:elementClass elementClass:nil withError:error];
                        DDLogInfo(@"Parse elements inside array DTO");
                        if (error && (*error || !parsedElement)) {
                            return nil;
                        } else {
                            [responseArray addObject:parsedElement];
                        }
                    }
                    return responseArray.copy;
                }
            } else {
                return responseObject;
            }
        } else {
            *error = [NSError errorWithDomain:@"Service Parser Error" code:1004 userInfo:@{NSLocalizedDescriptionKey: @"Service API Response expected Array but result object is not Array"}];
            return nil;
        }
    } else {
        // expected subclass of JSONModel
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id converted = [[class alloc] initWithDictionary:responseObject error:error];
            if (error && *error) {
                // convert error
                return nil;
            } else {
                return converted;
            }
        } else {
            *error = [NSError errorWithDomain:@"Service Parser Error" code:1004 userInfo:@{NSLocalizedDescriptionKey: @"Service API Response expected JSON Dictionary but result object is not JSON Dictionary"}];
            return nil;
        }
    }
}
@end
