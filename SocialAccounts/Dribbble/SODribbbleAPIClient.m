//
// Copyright 2011-2012 Adar Porat (https://github.com/aporat)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "SODribbbleAPIClient.h"

@implementation SODribbbleAPIClient

+ (instancetype)sharedClient {
    static SODribbbleAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SODribbbleAPIClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.dribbble.com/"]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
        
    return self;
}


- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                      sessionId:(NSString *)sessionId
                      authToken:(NSString *)authToken
                     parameters:(NSDictionary *)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters];
    
    NSHTTPCookie *sessionCookie = [NSHTTPCookie cookieWithProperties:@{
                                                                       NSHTTPCookieDomain: @".dribbble.com",
                                                                       NSHTTPCookiePath: @"",
                                                                       NSHTTPCookieName: @"_dribbble_session",
                                                                       NSHTTPCookieValue: sessionId}];
    
    NSHTTPCookie *authTokenCookie = [NSHTTPCookie cookieWithProperties:@{
                                                                         NSHTTPCookieDomain: @".dribbble.com",
                                                                         NSHTTPCookiePath: @"",
                                                                         NSHTTPCookieName: @"auth_token",
                                                                         NSHTTPCookieValue: authToken}];
    NSArray* cookies = @[sessionCookie, authTokenCookie];
    NSDictionary* headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    [request setAllHTTPHeaderFields:headers];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}



@end
