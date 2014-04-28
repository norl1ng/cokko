#import "TweetModel.h"
#import "RESTApi.h"
@implementation TweetModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             @"createdAt":@"created_at",
             @"tweetText":@"text",
             @"tweetLinks":@"entities.urls",
             @"tweetImages":@"entities.media",
             @"userName":@"user.name",
             @"userProfilePicture":@"user.profile_image_url"
             };
}

+ (NSValueTransformer *)userProfilePictureJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^(NSString *str) {
        str = [str stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
        return [NSURL URLWithString:str];
    }];
}

+ (NSValueTransformer *)tweetImagesJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *tweetImagesDict) {
        NSMutableArray *arr = [NSMutableArray new];
        
        for (NSDictionary *mediaDict in tweetImagesDict) {
            [arr addObject:mediaDict[@"media_url_https"]];
        }
        
        return [NSArray arrayWithArray:arr];
    }];
}

+ (NSValueTransformer *)tweetLinksJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *tweetImagesDict) {
        NSMutableArray *arr = [NSMutableArray new];
        
        for (NSDictionary *mediaDict in tweetImagesDict) {
            [arr addObject:[self removeNewlineCharactersFromString:mediaDict[@"url"]]];
        }
        
        return [NSArray arrayWithArray:arr];
    }];
}

+ (NSValueTransformer *)userNameJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSString *username) {
        return [self removeNewlineCharactersFromString:username];
    }];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSString *)removeNewlineCharactersFromString:(NSString *)string {
    return [string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"eee MMM dd HH:mm:ss ZZZZ yyyy";
    return dateFormatter;
}

@end