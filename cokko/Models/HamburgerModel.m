#import "HamburgerModel.h"

@implementation HamburgerModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"title": @"title",
             @"origin": @"origin",
             @"imageUrl": @"img_url",
             @"desc" : @"description"};
}

+ (NSValueTransformer *)imageUrlJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^(NSString *str) {
        return [NSURL URLWithString:str];
    }];
}

@end
