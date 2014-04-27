#import <Mantle/Mantle.h>

@interface TweetModel : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy, readonly) NSDate *createdAt;
@property (nonatomic, copy, readonly) NSString *tweetText;
@property (nonatomic, copy, readonly) NSArray *tweetLinks;
@property (nonatomic, copy, readonly) NSArray *tweetImages;
@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSURL *userProfilePicture;

@end