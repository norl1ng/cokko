// TODO: Make new video player class
// TODO: Change HamburgerAPI to HiQ twitter API
// TODO: Pause when out of view
// TODO: Bug on first cell not updating it's image

static NSString *const PATH = @"burgers.json";
static NSString *const CELL_REUSE_IDENTIFIER = @"CSSCell";
static NSString *const HEADER_REUSE_IDENTIFIER = @"CSSHeaderView";

#import "MainViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RESTApi.h"
#import "HamburgerModel.h"
#import "CSSCell.h"
#import <CSStickyHeaderFlowLayout/CSStickyHeaderFlowLayout.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <HCYoutubeParser/HCYoutubeParser.h>
#import <MediaPlayer/MediaPlayer.h>
#import <TSMessages/TSMessage.h>
#import "Reachability.h"
#import "UIImage+RoundImageWithBorder.h"

@interface MainViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet CSStickyHeaderFlowLayout *collectionViewLayout;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic, assign) NSTimeInterval videoPlayedDuration;

@end

@implementation MainViewController

#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addProgressHud];
    
    [self setupCSStickyHeader];
    
    [self checkForTheInternet];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"didEnterBackground" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:@"didBecomeActive" object:nil];
}

- (void)applicationDidEnterBackground {
    self.videoPlayedDuration = self.moviePlayer.moviePlayer.currentPlaybackTime;
    [self.moviePlayer.moviePlayer pause];
}

- (void)applicationDidBecomeActive {
    // TODO: pause -> play doesn't work as expected. For now readding the videoplayer
    [self addVideo];
    [self resumeVidePlayback];
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
    RACSignal *resultsSignal = [[RESTApi sharedApi] getHamburgersFromPath:PATH];
    
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
    self.progressHud.labelText = @"Loading burgers";
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
    CSSCell *cell = (CSSCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
    HamburgerModel *hamburger = self.results[indexPath.row];
    
    cell.nameLabel.text = hamburger.title;

    RACSignal *getImageSignal = [[RESTApi sharedApi] getImageForHamburger:hamburger];
    
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
        
        // Only run if cells have been loaded
        if (self.results) {
            [self addVideo];
        }
        
        return cell;
        
    }
    
    return nil;
}

#pragma mark - Video

- (void)addVideo {
    //TODO: loop or fade it out when done
    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:@"https://www.youtube.com/watch?v=A-JVT0XHGkQ&list=UUoKazMwDmwZEA6P9Jl2RkpQ"]];
    
    self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[videos objectForKey:@"hd720"]]];
    self.moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleNone;

    [self.moviePlayer.view setFrame:CGRectMake(0, -14.0f, 320.0f, 220.0f)];
    [self.headerView addSubview:self.moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishPlaying) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];;
}

- (void)videoDidFinishPlaying {
    [UIView animateWithDuration:1.0f animations:^{
        self.moviePlayer.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.moviePlayer.view removeFromSuperview];
        self.moviePlayer = nil;
    }];
}

- (void)resumeVidePlayback {
    if (self.videoPlayedDuration) {
        self.moviePlayer.moviePlayer.initialPlaybackTime = self.videoPlayedDuration;
    }
}

#pragma mark - Dealloc

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
