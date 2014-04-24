@class RACSignal;

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface RESTApi : AFHTTPSessionManager
+ (RESTApi *)sharedApi;
- (RACSignal *)getHamburgersFromPath:(NSString*)path;

@end
