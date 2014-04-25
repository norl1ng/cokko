#import "UIImage+RoundImageWithBorder.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (RoundImageWithBorder)

+ (UIImage *)roundedImage:(UIImage *)image size:(CGSize)size radius:(float)radius {
    
    CGRect imageFrame = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Create the clipping path and add it
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:imageFrame];
    [path addClip];
    [image drawInRect:imageFrame];
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    [path setLineWidth:5.0f];
    [path stroke];
    
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

@end
