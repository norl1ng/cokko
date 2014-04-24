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

@interface MainViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet CSStickyHeaderFlowLayout *collectionViewLayout;

@end

@implementation MainViewController

#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addProgressHud];
    
    [self setupCSStickyHeader];
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
    cell.nameLabel.text = ((HamburgerModel *)self.results[indexPath.row]).title;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    // Check the kind if it's CSStickyHeaderParallaxHeader
    if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        
        UICollectionReusableView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:HEADER_REUSE_IDENTIFIER
                                                                                   forIndexPath:indexPath];
        
        return cell;
        
    }
    
    return nil;
}

@end
