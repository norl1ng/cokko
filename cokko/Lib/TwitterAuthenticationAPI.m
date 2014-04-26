#import "TwitterAuthenticationAPI.h"

static NSString *const TWITTER_AUTH_URL = @"https://api.twitter.com/oauth2/token";
static NSString *const CONSUMER_KEY = @"dkUZIZvfKCup5pPoGBgRh4GoL";
static NSString *const CONSUMER_SECRET = @"HrXWlPf02KGVQ8FKz851cUSlWQeI1Y6cRCxCWfDCcjbH3E8leM";

@interface TwitterAuthenticationAPI ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;


@end

@implementation TwitterAuthenticationAPI
@synthesize manager;

+ (TwitterAuthenticationAPI *)sharedAuthentication {
    static TwitterAuthenticationAPI *sharedAuthentication;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:TWITTER_AUTH_URL];
        sharedAuthentication = [[TwitterAuthenticationAPI alloc] initWithBaseURL:url];
        sharedAuthentication.responseSerializer = [AFJSONResponseSerializer serializer];
        sharedAuthentication.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    
    sharedAuthentication.manager = [AFHTTPRequestOperationManager manager];
    
    return sharedAuthentication;
}

- (NSString *)base64encodedCredentials {
    NSString *consumerKeyRFC1738 = [CONSUMER_KEY stringByAddingPercentEscapesUsingEncoding:
                                    NSASCIIStringEncoding];
    NSString *consumerSecretRFC1738 = [CONSUMER_SECRET stringByAddingPercentEscapesUsingEncoding:
                                       NSASCIIStringEncoding];
    
    NSString *concatKeySecret = [[consumerKeyRFC1738 stringByAppendingString:@":"]    stringByAppendingString:consumerSecretRFC1738];
    
    NSData *plainData = [concatKeySecret dataUsingEncoding:NSUTF8StringEncoding];
    return [plainData base64EncodedStringWithOptions:0];
}

// Get access token
- (void)getTwitterBearerToken:(void (^) (NSDictionary *token))handler {

    if (self.bearerToken) return;
    
    // Set headers
    [self.manager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@",@"Basic", [self base64encodedCredentials]] forHTTPHeaderField:@"Authorization"];
    
    [self.manager POST:TWITTER_AUTH_URL parameters:@{@"grant_type":@"client_credentials"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        handler(responseObject);
        self.bearerToken = responseObject;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: Pass on to view for a TSMessage
        NSLog(@"Error authenticating with twitter: %@", error);
    }];
}

@end
