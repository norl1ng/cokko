@class RACSignal, HamburgerModel;

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface RESTApi : AFHTTPSessionManager
+ (RESTApi *)sharedApi;
- (RACSignal *)getHamburgersFromPath:(NSString*)path;
- (RACSignal *)getImageForHamburger:(HamburgerModel *)hamburger;

@end
