/*!
    Authenticates with Twitter API
 */

#import "AFHTTPSessionManager.h"
#import <AFNetworking.h>

@interface TwitterAuthenticationAPI : AFHTTPSessionManager
@property (nonatomic, strong) NSDictionary *bearerToken;
+ (TwitterAuthenticationAPI *)sharedAuthentication;
/*!
    @param Block [NSDictionary] Of most value is key:access_token wich is a base64 encoded bearer token that has to be attatched to all future requests
        against twitter API's
 */
- (void)getTwitterBearerToken:(void (^) (NSDictionary *token))handler;

@end
