@class RACSignal, TweetModel;

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface RESTApi : AFHTTPSessionManager
@property (nonatomic, strong) NSArray *profilePictureCache;
+ (RESTApi *)sharedApi;
- (RACSignal *)getTweetsFromHiQ;
- (RACSignal *)getTweetsForTwitterScreenName:(NSString *)screenName;
//- (RACSignal *)getProfilePictureForTweet:(TweetModel *)tweet;

@end
