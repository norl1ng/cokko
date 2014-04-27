@class RACSignal, TweetModel;

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface RESTApi : AFHTTPSessionManager
+ (RESTApi *)sharedApi;
- (RACSignal *)getTweetsFromHiQ;
- (RACSignal *)getTweetsForTwitterScreenName:(NSString *)screenName;
- (RACSignal *)getProfilePictureForTweet:(TweetModel *)tweet;

@end
