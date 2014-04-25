static NSString *const API_URL = @"http://hiqdevtest.appspot.com/";

#import "RESTApi.h"
#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "HamburgerModel.h"

@interface RESTApi ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

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
    sharedApi.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    return sharedApi;
}

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
