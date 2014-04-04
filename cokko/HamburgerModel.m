#import "HamburgerModel.h"

@implementation HamburgerModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"title": @"title",
             @"origin": @"origin",
             @"imgUrl": @"img_url",
             @"desc" : @"description"};
}

+ (NSValueTransformer *)imgUrlJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^(NSString *str) {
        return [NSURL URLWithString:str];
    }];
}

@end
