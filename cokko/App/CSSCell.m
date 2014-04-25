#import "CSSCell.h"

@implementation CSSCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
    }
 
    return self;
}

@end
