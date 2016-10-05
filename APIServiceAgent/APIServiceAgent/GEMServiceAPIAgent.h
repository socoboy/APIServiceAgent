//
//  HLServiceAPIRequestBuilder.h
//  hocvalam
//
//  Created by Tung Duong Thanh on 7/27/16.
//  Copyright © 2016 GEM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

/**
 *  This is an Abstract Class for working with APIService in GEM company,
 *      - You have to create subclass for each project which using APIService to inherit all functionality here
 *      - You have to implement your own way methods marked as "HAVE_TO_IMPLEMENT_IN_SUBCLASS" belows to work able with APIServices
 *
 *  Get authorized request to request to service api with authorized token
 *  Get unauthorized request to request to service api without authorized token
 *
 */

@interface GEMServiceAPIAgent : AFHTTPSessionManager

+ (NSMutableURLRequest *)getAuthorizedRequestWithPath:(NSString *)path
                                               params:(NSDictionary *)params
                                                error:(NSError *__autoreleasing *)error;

+ (NSMutableURLRequest *)postAuthorizedRequestWithPath:(NSString *)path
                                                params:(NSDictionary *)params
                                               payload:(NSData *)payload
                                                 error:(NSError *__autoreleasing *)error;

+ (NSMutableURLRequest *)postAutorizedMultipartRequestWithParam:(NSDictionary *)params
                                                           path:(NSString *)path
                                      constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                                          error:(NSError *__autoreleasing *)error;

+ (NSMutableURLRequest *)getUnauthorizedRequestWithPath:(NSString *)path
                                                 params:(NSDictionary *)params
                                                  error:(NSError *__autoreleasing *)error;

+ (NSMutableURLRequest *)postUnauthorizedRequestWithPath:(NSString *)path
                                                  params:(NSDictionary *)params
                                                 payload:(NSData *)payload
                                                   error:(NSError *__autoreleasing *)error;


/**
 *  Base start request method
 *
 *  @param request              request
 *  @param uploadProgress       upload-progress-block
 *  @param downloadProgress     download-progress-block
 *  @param responseMappingBlock response-mapping-block: current method will use this block to
 *                              manage
 *  @param completion           completion-block, run on default a background GCD queue
 *
 *  @return NSURLSessionTask to cancel it need
 */
+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
                    uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgress
                  downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgress
              responseMappingBlock:(id (^)(id rawResponse, NSError *__autoreleasing *error))responseMappingBlock
                        completion:(void(^)(id responseDataObject, NSError *error))completion;

/**
 *  Base start request method
 *
 *  @param request              request
 *  @param uploadProgress       upload-progress-block
 *  @param downloadProgress     download-progress-block
 *  @param responseMappingBlock response-mapping-block: current method will use this block to
 *                              manage
 *  @param completion           completion-block, run on completionQueue
 *  @param completionQueue      completionQueue to run completion-block
 *
 *  @return NSURLSessionTask to cancel it need
 */
+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
                    uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgress
                  downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgress
              responseMappingBlock:(id (^)(id rawResponse, NSError *__autoreleasing *error))responseMappingBlock
                        completion:(void(^)(id responseDataObject, NSError *error))completion
           dispatchCompletionQueue:(NSOperationQueue *)completionQueue;

/**
 *  Start request
 *
 *  @param request            http request
 *  @param uploadProgress     upload progress block
 *  @param downloadProgress   download progress block
 *  @param expectedClass      expected response class, in one of three type: JSONModel subclasses, String, array or dictionary and nil
 *  @param completion         completion block, will be called with response data which transported to the expected class, error if have run on a default background GCD queue
 *
 *  @return NSURLSessionTask for cancel if need
 */
+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
                    uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgress
                  downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgress
             expectedResponseClass:(Class)expectedClass
                      elementClass:(Class)elementClass
                        completion:(void(^)(id responseDataObject, NSError *error))completion;

/**
 *  Start request
 *
 *  @param request            http request
 *  @param uploadProgress     upload progress block
 *  @param downloadProgress   download progress block
 *  @param expectedClass      expected response class, in one of three type: JSONModel subclasses, String, array or dictionary and nil
 *  @param completion         completion block, will be called with response data which transported to the expected class, error if have, run on copmletionQueue
 *  @param completionQueue      completionQueue to run completion-block
 *
 *  @return NSURLSessionTask for cancel if need
 */
+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
                    uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgress
                  downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgress
             expectedResponseClass:(Class)expectedClass
                      elementClass:(Class)elementClass
                        completion:(void(^)(id responseDataObject, NSError *error))completion
           dispatchCompletionQueue:(NSOperationQueue *)completionQueue;


+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
             expectedResponseClass:(Class)expectedClass
                        completion:(void(^)(id responseDataObject, NSError *error))completion;

+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
             expectedResponseClass:(Class)expectedClass
                        completion:(void(^)(id responseDataObject, NSError *error))completion
           dispatchCompletionQueue:(NSOperationQueue *)completionQueue;

/**
 *  Start request for expecting Array with external element class
 *
 *  @param request      Request
 *  @param elementClass Expecting element class in Array Result
 *  @param completion   completion block run on a background GCD queue
 *
 *  @return NSURLSessionTask for cancel if needed
 */
+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
     expectedArrayWithElementClass:(Class)elementClass
                        completion:(void(^)(id responseDataObject, NSError *error))completion;

/**
 *  Start request for expecting Array with external element class
 *
 *  @param request              Request
 *  @param elementClass         Expecting element class in Array Result
 *  @param completion           completion block run on completionQueue
 *  @param completionQueue      completionQueue to run completion-block
 *
 *  @return NSURLSessionTask for cancel if needed
 */
+ (NSURLSessionTask *)startRequest:(NSURLRequest *)request
     expectedArrayWithElementClass:(Class)elementClass
                        completion:(void(^)(id responseDataObject, NSError *error))completion
           dispatchCompletionQueue:(NSOperationQueue *)completionQueue;


/**
 *  HAVE_TO_IMPLEMENT_IN_SUBCLASS - This method add authentication to a request
 *
 *  @param request unauthorized request
 *
 *  @return authorized request
 */
- (NSMutableURLRequest *)addAuthorizedTokenToRequest:(NSMutableURLRequest *)request;

/**
 *  HAVE_TO_IMPLEMENT_IN_SUBCLASS - This method need to handle service error with particular response
 *  @param error            Service error received
 *  @param response         NSURLResponse received
 *  @param responseObject   Response data received
 *  @return handled error, nil if no need to handle
 */
+ (NSError *)handleServiceError:(NSError *)serviceError
                       response:(NSURLResponse *)response
                 responseObject:(id)responseDataObject;

/*
 *  Privated method
 */
+ (id)convertResponseObject:(id)responseObject toDTOObjectClass:(Class)class elementClass:(Class)elementClass withError:(NSError *__autoreleasing *)error;
@end













