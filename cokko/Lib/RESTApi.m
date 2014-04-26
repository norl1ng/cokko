static NSString *const API_URL = @"http://hiqdevtest.appspot.com/";
//https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=twitterapi&count=2

#import "RESTApi.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "HamburgerModel.h"
#import "TwitterAuthenticationAPI.h"

@interface RESTApi ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSDictionary *bearerToken;

@end

@implementation RESTApi
@synthesize manager;

+ (RESTApi *)sharedApi {
    static RESTApi *sharedApi;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:API_URL];
        sharedApi = [[RESTApi alloc] initWithBaseURL:url];
        sharedApi.responseSerializer = [AFJSONResponseSerializer serializer];
        sharedApi.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    
    sharedApi.manager = [AFHTTPRequestOperationManager manager];
    
#warning TESTING
    [[TwitterAuthenticationAPI sharedAuthentication] getTwitterBearerToken:^(NSDictionary *token) {
        if (!sharedApi.bearerToken) {
            
            // Set header with base64 encoded access token for all future requests
            [sharedApi.manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@",@"Bearer", token[@"access_token"]] forHTTPHeaderField:@"Authorization"];
            sharedApi.bearerToken = token;
            
            [sharedApi.manager GET:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=norl1ng" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"%@", responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
            }];
        }
    }];
    
    return sharedApi;
}

#pragma mark - OLD HAMBURGER VERSION

- (RACSignal *)getHamburgersFromPath:(NSString*)path {
    RACSubject *getSignal = [RACSubject subject];
    
    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        [getSignal sendNext:[self parseResponseData:responseObject]];
        [getSignal sendCompleted];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [getSignal sendError:error];
    }];
    
    return [getSignal deliverOn:[RACScheduler scheduler]];
}

- (RACSignal *)getImageForHamburger:(HamburgerModel *)hamburger {
    if (!hamburger.imageUrl) return nil;
    
    RACSubject *getSignal = [RACSubject subject];
        [self.manager GET:[hamburger.imageUrl absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [getSignal sendNext:[self parseImageData:responseObject]];
            [getSignal sendCompleted];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [getSignal sendError:error];
        }];
    
    return [getSignal deliverOn:[RACScheduler mainThreadScheduler]];
}

- (UIImage *)parseImageData:(id)data {
    return [UIImage imageWithData:data];
}

- (NSArray *)parseResponseData:(NSArray *)data {
    return [[data.rac_sequence map:^id(NSDictionary *dictionary) {
        return [MTLJSONAdapter modelOfClass:HamburgerModel.class fromJSONDictionary:dictionary error:nil];
    }] array];
}

@end
