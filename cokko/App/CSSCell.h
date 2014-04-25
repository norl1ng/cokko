#import <UIKit/UIKit.h>

@interface CSSCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end
