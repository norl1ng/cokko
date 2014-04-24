#import <Mantle/Mantle.h>

@interface HamburgerModel : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *desc;
@property (nonatomic, copy, readonly) NSURL *imageUrl;
@property (nonatomic, copy, readonly) NSString *origin;

@end