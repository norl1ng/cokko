static NSString *const TWITTER_SCREEN_NAME_URL = @"statuses/user_timeline.json?screen_name=";
static NSString *const TWITTER_BASE_URL = @"https://api.twitter.com/1.1/";

#import "RESTApi.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TwitterAuthenticationAPI.h"
#import "TweetModel.h"

@interface RESTApi ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, assign) BOOL isAuthenticated;

@end

@implementation RESTApi
@synthesize manager;

+ (RESTApi *)sharedApi {
    static RESTApi *sharedApi;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:TWITTER_BASE_URL];
        sharedApi = [[RESTApi alloc] initWithBaseURL:url];
        sharedApi.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    
    sharedApi.manager = [AFHTTPRequestOperationManager manager];
    sharedApi.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // Request authentication bearer token
    [sharedApi authenticateWithTwitter];
    
    return sharedApi;
}

- (void)authenticateWithTwitter {
    if (self.isAuthenticated) return;
    
    [[TwitterAuthenticationAPI sharedAuthentication] getTwitterBearerToken:^(NSDictionary *token) {
        // Set header with base64 encoded access token for all future requests
        
        [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@", @"Bearer", token[@"access_token"]] forHTTPHeaderField:@"Authorization"];
        self.isAuthenticated = YES;
    }];
}

/*!
    If called before twitter bearer token has been recived it will wait until authentication is done.
 */
- (RACSignal *)getTweetsForTwitterScreenName:(NSString *)screenName {
    RACSubject *getSignal = [RACSubject subject];

        [[RACObserve(self, isAuthenticated)
          filter:^(NSNumber *authenticated) {
              return [authenticated boolValue];
          }] subscribeNext:^(NSNumber *authenticated) {
             [self.manager GET:[self urlPathForScreenName:@"norl1ng"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [getSignal sendNext:[self parseTweets:responseObject]];
                 [getSignal sendCompleted];
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@">>> %@", error);
                 [getSignal sendError:error];
             }];
         }];
    
    return getSignal;
}

- (RACSignal *)getProfilePictureForTweet:(TweetModel *)tweet {

    RACSubject *getSignal = [RACSubject subject];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:tweet.userProfilePicture];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [getSignal sendNext:responseObject];
        [getSignal sendCompleted];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [getSignal sendError:error];
    }
     ];
    [operation start];
    
    return [getSignal deliverOn:[RACScheduler mainThreadScheduler]];
}


#pragma mark - Helpers

- (NSString *)urlPathForScreenName:(NSString *)screenName {
    return [NSString stringWithFormat:@"%@%@%@&count=10", TWITTER_BASE_URL, TWITTER_SCREEN_NAME_URL, screenName];
}

- (NSArray *)parseTweets:(NSArray *)data {
    return [[data.rac_sequence map:^id(NSDictionary *dictionary) {
        return [MTLJSONAdapter modelOfClass:TweetModel.class fromJSONDictionary:dictionary error:nil];
    }] array];
}

@end