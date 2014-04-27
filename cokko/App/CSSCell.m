#import "CSSCell.h"

@implementation CSSCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
 
    return self;
}

- (void)awakeFromNib {
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.bounds byRoundingCorners: UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii: (CGSize){42.0f, 42.0f}].CGPath;
    
    self.layer.mask = maskLayer;
    
    self.tweetBody.numberOfLines = 0;
}

@end
