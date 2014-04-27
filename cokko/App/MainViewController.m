// TODO: Make new video player class
// TODO: Change HamburgerAPI to HiQ twitter API
// TODO: Pause when scrolled out of view
// TODO: Support landscape but play video in fullscreen
// TODO: Bug on first cell not updating it's image
// TODO: When in landscape play movie at fullscreen

static NSString *const CELL_REUSE_IDENTIFIER = @"CSSCell";
static NSString *const HEADER_REUSE_IDENTIFIER = @"CSSHeaderView";

#import "MainViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RESTApi.h"
#import "TweetModel.h"
#import "CSSCell.h"
#import <CSStickyHeaderFlowLayout/CSStickyHeaderFlowLayout.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <TSMessages/TSMessage.h>
#import "Reachability.h"
#import "UIImage+RoundImageWithBorder.h"
#import "HiqViedoPlayerViewController.h"

@interface MainViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet CSStickyHeaderFlowLayout *collectionViewLayout;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) HiqViedoPlayerViewController *moviePlayer;

@end

@implementation MainViewController

#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addVideoPlayer];
    
    [self addProgressHud];
    
    [self setupCSStickyHeader];
    
    [self checkForTheInternet];
}

#pragma mark - Video player

- (void)addVideoPlayer {
    __weak typeof(self) weakSelf = self;
    
    [[RACObserve(self, headerView) filter:^BOOL(UIView *headerView) {
        return headerView != nil && !weakSelf.moviePlayer;
    }] subscribeNext:^(UIView *headerView) {
        weakSelf.moviePlayer = [[HiqViedoPlayerViewController alloc] init];
        [weakSelf.moviePlayer addVideoPlayerToView:self.headerView];
        [weakSelf.moviePlayer resumeVideoPlayback];
    }];
}

#pragma mark - CSStickyHeader

- (void)setupCSStickyHeader {
    CSStickyHeaderFlowLayout *layout = (id)self.collectionViewLayout;
    layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(320.0f, 150.0f);
    
    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(320, 200);
    }
    
    UINib *headerNib = [UINib nibWithNibName:HEADER_REUSE_IDENTIFIER bundle:nil];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader withReuseIdentifier:HEADER_REUSE_IDENTIFIER];
    [self setupDataBindings];
}


#pragma mark - Bind -> model -> view

- (void)setupDataBindings {
    RACSignal *resultsSignal = [[RESTApi sharedApi] getTweetsFromHiQ];
    
    [resultsSignal subscribeNext:^(NSArray *results) {
        self.results = results;
    }];

    __weak typeof (self) weakSelf = self;

    [[RACObserve(self, results) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        [weakSelf.collectionView reloadData];
        [self.progressHud hide:YES];
    }];
}


#pragma mark - ProgressHud

- (void)addProgressHud {
    self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHud.mode = MBProgressHUDModeIndeterminate;
    self.progressHud.labelText = @"Loading tweets";
}


#pragma mark - Check internet connectiviy

- (void)checkForTheInternet {
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [TSMessage showNotificationInViewController:self title:@"Ops!" subtitle:@"You sir, has no internetz!" type:TSMessageNotificationTypeError];
        });
    };
    
    [reach startNotifier];
}

#pragma mark - CollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.results.count;
}


#pragma mark - CollectionView Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __block __weak CSSCell *cell = (CSSCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    TweetModel *tweet = self.results[indexPath.row];
    
    cell.nameLabel.text = tweet.userName;
    cell.tweetBody.text = tweet.tweetText;
    
    RACSignal *getImageSignal = [[RESTApi sharedApi] getProfilePictureForTweet:tweet];

    [getImageSignal subscribeNext:^(id image) {
        if ([image isKindOfClass:[UIImage class]]) {
            CGFloat imageWidth = cell.imageView.frame.size.width;
            cell.imageView.image = [UIImage roundedImage:(UIImage *)image size:CGSizeMake(imageWidth, imageWidth) radius:imageWidth / 2.0f];
            [cell.loadingIndicator removeFromSuperview];
            [cell setNeedsLayout];
            [cell setNeedsDisplay];
        }
    }];
    
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    // Check the kind if it's CSStickyHeaderParallaxHeader
    if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        
        UICollectionReusableView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:HEADER_REUSE_IDENTIFIER
                                                                                   forIndexPath:indexPath];
        
        self.headerView = cell;
        
        return cell;
        
    }
    
    return nil;
}

@end
